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
        // 失敗のたびに新しいPodが作られ、planetiler initContainerがosm.pbf
        // (日本全域、GB単位)を最初からダウンロードし直してしまう(emptyDirは
        // Pod単位のため、リトライで前回のダウンロード結果を引き継げない)。
        // Geofabrikへの負荷・実行時間の無駄を避けるため自動リトライはしない。
        backoffLimit: 0,
        template: {
          metadata: {
            labels: labels(app.name + '-basemap-generate'),
          },
          spec: {
            serviceAccountName: (import '../sa.jsonnet').metadata.name,
            imagePullSecrets: [{ name: 'ghcr-login-secret' }],
            restartPolicy: 'Never',
            securityContext: {
              runAsNonRoot: true,
              runAsUser: 65532,
              runAsGroup: 65532,
            },
            initContainers: [
              (import '../../../components/container.libsonnet') {
                name: 'planetiler',
                image: 'ghcr.io/onthegomap/planetiler:0.10.2',
                imagePullPolicy: 'IfNotPresent',
                args: [
                  'generate-custom',
                  '--schema=/schema/schema.yml',
                  // 日本全域のOSM抽出データ
                  '--osm_pbf_url=https://download.geofabrik.de/asia/japan-latest.osm.pbf',
                  '--dataset_version=$(DATASET_VERSION)',
                  '--output=/work/basemap.pmtiles',
                  '--tmpdir=/work/tmp',
                  '--download',
                ],
                env: [
                  {
                    name: 'DATASET_VERSION',
                    valueFrom: { fieldRef: { fieldPath: 'metadata.uid' } },
                  },
                ],
                resources: {
                  requests: { cpu: '2', memory: '6Gi', 'ephemeral-storage': '15Gi' },
                  limits: { cpu: '4', memory: '10Gi', 'ephemeral-storage': '30Gi' },
                },
                volumeMounts: [
                  { name: 'work', mountPath: '/work' },
                  { name: 'schema', mountPath: '/schema', readOnly: true },
                ],
              },
              (import '../../../components/container.libsonnet') {
                name: 'fonts-extract',
                image: 'docker.io/curlimages/curl:8.21.0',
                imagePullPolicy: 'IfNotPresent',
                command: ['sh', '-c'],
                args: [
                  |||
                    set -eu
                    mkdir -p /work/fonts
                    curl -fsSL https://codeload.github.com/openmaptiles/fonts/tar.gz/refs/heads/gh-pages \
                      | tar xz -C /work/fonts --strip-components=1 "fonts-gh-pages/Klokantech Noto Sans Regular"
                  |||,
                ],
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
              (import '../../../components/container.libsonnet') {
                name: 'rclone',
                image: 'ghcr.io/rclone/rclone:1.75.0',
                imagePullPolicy: 'IfNotPresent',
                command: ['sh', '-c'],
                args: [
                  // --s3-no-check-bucketが無いと、multi-thread copy時にrcloneが
                  // アップロード前にバケット存在確認→無ければCreateBucketを試みる。
                  // Piccaのs3IrsaロールにCreateBucket権限は無く(bucket作成はinfra
                  // manifest側で静的に行う運用、storage.goのEnsureBucketと同じ方針)、
                  // 403 AccessDeniedで失敗するため明示的に無効化する。
                  |||
                    set -eu
                    rclone copyto /work/basemap.pmtiles seaweedfs:picca/basemap/basemap.pmtiles \
                      --s3-no-check-bucket \
                      --header-upload "Cache-Control: public, max-age=31536000, immutable"
                    rclone copy /work/fonts seaweedfs:picca/fonts \
                      --s3-no-check-bucket \
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
                name: 'work',
                emptyDir: {},
              },
              {
                name: 'schema',
                image: { reference: 'ghcr.io/walnuts1018/picca/basemap-schema:v0.0.45' },
              },
            ] + s3Irsa.volumes,
          },
        },
      },
    },
  },
}
