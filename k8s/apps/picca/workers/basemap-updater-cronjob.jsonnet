local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
local commonEnv = import '../env.libsonnet';
local externalSecret = import '../external-secret.jsonnet';
local s3Irsa = import '../s3-irsa.libsonnet';
{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: app.name + '-basemap-updater',
    namespace: app.namespace,
    labels: labels(app.name + '-basemap-updater'),
  },
  spec: {
    // OSMデータ自体は高頻度更新が不要なため月次実行(毎月1日 03:00 JST)。
    schedule: '0 3 1 * *',
    timeZone: 'Asia/Tokyo',
    // manifestベースの差分アップロード(S3上のmanifest.jsonを読み書きする)が多重実行に対して安全ではないため、前回実行が残っていれば新規実行を禁止する。
    concurrencyPolicy: 'Forbid',
    startingDeadlineSeconds: 300,
    jobTemplate: {
      spec: {
        // BASEMAP_RUN_TIMEOUT(デフォルト2h)より十分長く確保する。
        activeDeadlineSeconds: 3 * 60 * 60,
        backoffLimit: 2,
        template: {
          metadata: {
            labels: labels(app.name + '-basemap-updater'),
          },
          spec: {
            serviceAccountName: (import '../sa.jsonnet').metadata.name,
            imagePullSecrets: [{ name: 'ghcr-login-secret' }],
            restartPolicy: 'OnFailure',
            containers: [
              (import '../../../components/container.libsonnet') {
                name: 'basemap-updater',
                image: 'ghcr.io/walnuts1018/picca/basemap-updater:v0.0.44',
                imagePullPolicy: 'IfNotPresent',
                envFrom: [
                  { secretRef: { name: externalSecret.spec.target.name } },
                ],
                env: commonEnv + s3Irsa.env + [
                  {
                    name: 'OTEL_SERVICE_NAME',
                    value: 'picca-basemap-updater',
                  },
                  {
                    // 日本全域のOSM抽出データ(Geofabrik)。対象地域を広げる場合はresources/emptyDirのサイズも合わせて見直すこと。
                    name: 'OSM_PBF_URL',
                    value: 'https://download.geofabrik.de/asia/japan-latest.osm.pbf',
                  },
                ],
                resources: {
                  requests: {
                    cpu: '500m',
                    memory: '2Gi',
                  },
                  limits: {
                    cpu: '2',
                    memory: '8Gi',
                  },
                },
                volumeMounts: [
                  {
                    name: 'tmp',
                    mountPath: '/tmp',
                  },
                ] + s3Irsa.volumeMounts,
              },
            ],
            securityContext: {
              runAsNonRoot: true,
              runAsUser: 65532,
              runAsGroup: 65532,
            },
            volumes: [
              {
                name: 'tmp',
                emptyDir: { sizeLimit: '20Gi' },
              },
            ] + s3Irsa.volumes,
          },
        },
      },
    },
  },
}
