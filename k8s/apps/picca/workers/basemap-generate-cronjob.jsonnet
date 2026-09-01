local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
local commonEnv = import '../env.libsonnet';
local externalSecret = import '../external-secret.jsonnet';
local s3Irsa = import '../s3-irsa.libsonnet';
{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: app.name + '-basemap-generate',
    namespace: app.namespace,
    labels: labels(app.name + '-basemap-generate'),
  },
  spec: {
    schedule: '0 3 1 * *',  // 毎月1日 03:00
    timeZone: 'Asia/Tokyo',
    concurrencyPolicy: 'Forbid',
    startingDeadlineSeconds: 300,
    jobTemplate: {
      spec: {
        activeDeadlineSeconds: 3 * 60 * 60,
        backoffLimit: 2,
        template: {
          metadata: {
            labels: labels(app.name + '-basemap-generate'),
          },
          spec: {
            serviceAccountName: (import '../sa.jsonnet').metadata.name,
            imagePullSecrets: [{ name: 'ghcr-login-secret' }],
            // initContainerが複数stepにまたがるため、リトライはPod単位(restartPolicy)
            // ではなくJob単位(backoffLimit)で行う。
            restartPolicy: 'Never',
            securityContext: {
              runAsNonRoot: true,
              runAsUser: 65532,
              runAsGroup: 65532,
            },
            initContainers: [
              // Planetiler公式image(https://github.com/onthegomap/planetiler)で
              // tools/basemap/schema.ymlからbasemap.pmtilesを生成する。tilemakerの
              // ような独自ソースビルドは行わない。
              (import '../../../components/container.libsonnet') {
                name: 'planetiler',
                image: 'ghcr.io/onthegomap/planetiler:0.10.2',
                imagePullPolicy: 'IfNotPresent',
                args: [
                  'generate-custom',
                  '--schema=/schema/schema.yml',
                  // 日本全域のOSM抽出データ(Geofabrik)。旧basemap-updater CronJobと同じ地域。
                  '--osm_pbf_url=https://download.geofabrik.de/asia/japan-latest.osm.pbf',
                  '--dataset_version=$(DATASET_VERSION)',
                  '--output=/work/basemap.pmtiles',
                  '--tmpdir=/work/tmp',
                ],
                env: [
                  {
                    // Kubernetes Downward APIでPod UIDを渡し、生成のたびにtileset versionが
                    // 変わるようにする。MartinのtilejsonUrlVersionParamでcache bustに使う。
                    name: 'DATASET_VERSION',
                    valueFrom: { fieldRef: { fieldPath: 'metadata.uid' } },
                  },
                ],
                // Planetiler公式推奨: JVMヒープはOSM PBFファイルサイズの概ね1.5〜2倍程度。
                // 日本全域のosm.pbfは概ね2〜3GB程度のため、余裕を持たせる。
                // ephemeral-storageのrequests/limitsは、/workのemptyDir(osm.pbf+
                // Planetilerの一時データ+PMTiles出力、日本全域規模で合計十数GB程度を
                // 想定)がnode root diskを圧迫しないようにするための指定。requestsで
                // schedulerに空き容量のあるnodeを選ばせ、limitsを超えたらkubeletが
                // Podをevictする(LocalStorageCapacityIsolation)。専用の
                // StorageClass/PVCを別途用意するより単純なため、node root diskからの
                // 隔離が必須でない限りこちらを優先する。
                resources: {
                  requests: { cpu: '2', memory: '6Gi', 'ephemeral-storage': '15Gi' },
                  limits: { cpu: '4', memory: '10Gi', 'ephemeral-storage': '30Gi' },
                },
                volumeMounts: [
                  { name: 'work', mountPath: '/work' },
                  { name: 'schema', mountPath: '/schema', readOnly: true },
                ],
              },
              // place-label描画に必要なglyphs(SDF PBF)を、OFLライセンスの生成済み
              // フォント(openmaptiles/fonts)のtarballから取り出す。fontsはbasemapとは
              // ライフサイクルが異なるが、新規の独自Go/shellアプリを作らないという方針の
              // もと、既製toolであるcurl+tarの組み合わせで完結させる(docs/tasks/00291-map.md
              // 3.5章相当)。
              (import '../../../components/container.libsonnet') {
                name: 'fonts-extract',
                image: 'docker.io/library/alpine:3.22',
                imagePullPolicy: 'IfNotPresent',
                command: ['sh', '-c'],
                args: [
                  |||
                    set -eu
                    apk add --no-cache curl tar
                    mkdir -p /work/fonts
                    curl -fsSL https://codeload.github.com/openmaptiles/fonts/tar.gz/refs/heads/gh-pages \
                      | tar xz -C /work/fonts --strip-components=2 "fonts-gh-pages/Noto Sans Regular"
                  |||,
                ],
                securityContext: {
                  // apk addのため一時的にrootのwritable filesystemが必要。
                  readOnlyRootFilesystem: false,
                },
                resources: {
                  requests: { cpu: '100m', memory: '128Mi' },
                  limits: { memory: '512Mi' },
                },
                volumeMounts: [
                  { name: 'work', mountPath: '/work' },
                ],
              },
            ],
            containers: [
              // rclone公式imageでbasemap.pmtiles・fontsをSeaweedFS S3の固定keyへ配置する。
              // S3アップロード用の独自Goコードは書かない。
              (import '../../../components/container.libsonnet') {
                name: 'rclone',
                image: 'ghcr.io/rclone/rclone:1.75.0',
                imagePullPolicy: 'IfNotPresent',
                command: ['sh', '-c'],
                args: [
                  |||
                    set -eu
                    rclone copyto /work/basemap.pmtiles seaweedfs:picca/basemap/basemap.pmtiles \
                      --header-upload "Cache-Control: public, max-age=31536000, immutable"
                    rclone copy /work/fonts seaweedfs:picca/fonts \
                      --header-upload "Cache-Control: public, max-age=86400, must-revalidate"
                  |||,
                ],
                env: commonEnv + s3Irsa.env + [
                  {
                    name: 'RCLONE_CONFIG_SEAWEEDFS_TYPE',
                    value: 's3',
                  },
                  {
                    name: 'RCLONE_CONFIG_SEAWEEDFS_PROVIDER',
                    value: 'Other',
                  },
                  {
                    name: 'RCLONE_CONFIG_SEAWEEDFS_ENV_AUTH',
                    value: 'true',
                  },
                  {
                    // env.libsonnetのAWS_ENDPOINT_URL_S3と同じ値(SeaweedFS filerのS3互換
                    // endpoint)をrcloneのendpointへ流用する。
                    name: 'RCLONE_CONFIG_SEAWEEDFS_ENDPOINT',
                    value: 'http://seaweedfs-default-filer.seaweedfs.svc.cluster.local:8333',
                  },
                  {
                    name: 'RCLONE_CONFIG_SEAWEEDFS_REGION',
                    value: 'us-east-1',
                  },
                  {
                    name: 'OTEL_SERVICE_NAME',
                    value: 'picca-basemap-generate',
                  },
                ],
                resources: {
                  requests: { cpu: '100m', memory: '128Mi' },
                  limits: { memory: '512Mi' },
                },
                volumeMounts: [
                  { name: 'work', mountPath: '/work', readOnly: true },
                ] + s3Irsa.volumeMounts,
              },
            ],
            volumes: [
              {
                // Planetilerの一時データ(OSM PBF展開・feature sort等)+PMTiles出力は
                // 日本全域規模でGB単位になりうるが、node root diskの保護は専用
                // StorageClass/PVCではなく、上記planetilerコンテナの
                // ephemeral-storage requests/limits(LocalStorageCapacityIsolation)
                // で行う。Job終了時にPodごと自動削除される点はGeneric Ephemeral
                // Volumeと変わらない。
                name: 'work',
                emptyDir: {},
              },
              {
                // tools/basemap/schema.yml(picca側リポジトリのソース)は、Picca CIが
                // OCI artifactとしてghcr.ioへpushしたものをimage volumeSource(K8s 1.31+)
                // で直接マウントする。infra側でConfigMapとして手動コピーを保持しない
                // (旧tilemaker時代にconfig.json/process.luaをPicca製Dockerイメージへ
                // 焼き込んでいたのと同じ、「app-specific configはPicca側が単一の
                // source of truthとしてartifact配布し、infraはtag参照するだけ」という
                // 設計に合わせている)。
                // このクラスタ(k8s/init/kurumi.md)はCRI-O(1.36系)を使っており、
                // CRI-O 1.33+のOCI Artifact mountはlayer blobをtar展開せずそのまま
                // ファイルとして配置するため、artifact側はtar化していない(layerの
                // org.opencontainers.image.titleアノテーションがファイル名になり、
                // このmountPath直下に`schema.yml`として見える)。
                name: 'schema',
                image: { reference: 'ghcr.io/walnuts1018/picca/basemap-schema:v0.0.44' },
              },
            ] + s3Irsa.volumes,
          },
        },
      },
    },
  },
}
