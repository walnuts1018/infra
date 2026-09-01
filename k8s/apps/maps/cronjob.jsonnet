local container = import '../../components/container.libsonnet';
local app = import 'app.json5';
local rcloneConfig = import 'configmap-rclone.jsonnet';
local configTemplate = import 'configmap-template.jsonnet';
local deployment = import 'deployment.jsonnet';
local s3Irsa = import 's3-irsa.libsonnet';
local updaterSa = import 'updater-sa.jsonnet';
local readSecretName = (import 'external-secret.jsonnet').spec.target.name;

// 5ステップの依存関係(shellでの条件分岐は使わず、initContainer失敗で後続が
// 実行されないKubernetesの標準挙動だけで表現する):
//   1. rclone-sync:     upstream -> mapsバケットへ同期(WebIdentity AssumeRole、変更が無ければskip)
//   2. presign:         mapsバケットのobjectに対するpresigned URLを発行(読み取り専用static key)
//   3. render-config:   presigned URLを埋め込んだVersaTiles ConfigMapマニフェストを生成
//   4. apply-config:    そのConfigMapをapply(ArgoCD管理外、update-cronjobだけが所有)
//   5. rollout-restart: VersaTiles Serverを再起動(新しいconfigを読み込ませる)
{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: app.name + '-update',
    namespace: app.namespace,
  },
  spec: {
    schedule: '0 3 1 * *',
    timeZone: 'Asia/Tokyo',
    concurrencyPolicy: 'Forbid',
    startingDeadlineSeconds: 3600,
    successfulJobsHistoryLimit: 3,
    failedJobsHistoryLimit: 3,
    jobTemplate: {
      spec: {
        backoffLimit: 2,
        activeDeadlineSeconds: 86400,
        template: {
          metadata: {
            labels: (import '../../components/labels.libsonnet')(app.name + '-update'),
          },
          spec: {
            serviceAccountName: updaterSa.metadata.name,
            restartPolicy: 'Never',
            initContainers: [
              (container) {
                name: 'rclone-sync',
                image: 'ghcr.io/rclone/rclone:1.75.0',
                command: ['rclone'],
                args: [
                  '--config=/config/rclone.conf',
                  'copyto',
                  ':http,url=https://download.versatiles.org/:osm-landcover.versatiles',
                  'seaweedmaps:maps/osm-landcover.versatiles',
                  '--retries=5',
                  '--low-level-retries=20',
                  '--retries-sleep=30s',
                  '--timeout=10m',
                  '--contimeout=30s',
                  '--s3-chunk-size=64M',
                  '--s3-upload-concurrency=4',
                ],
                env: s3Irsa.env,
                resources: {
                  requests: { cpu: '100m', memory: '128Mi' },
                  limits: { memory: '512Mi' },
                },
                volumeMounts: [
                  { name: 'rclone-config', mountPath: '/config', readOnly: true },
                ] + s3Irsa.volumeMounts,
              },
              (container) {
                name: 'presign',
                image: 'ghcr.io/rclone/rclone:1.75.0',
                // 標準出力を1行ファイルへ書き出すだけの用途に限定してshを使う
                // (rclone linkの出力をそのままVersaTiles configへ埋め込むための橋渡し)。
                command: ['sh', '-c'],
                args: [
                  'rclone --config=/config/rclone.conf link --expire=840h seaweedmapsread:maps/osm-landcover.versatiles > /work/presigned-url',
                ],
                envFrom: [
                  { secretRef: { name: readSecretName } },
                ],
                resources: {
                  requests: { cpu: '50m', memory: '64Mi' },
                  limits: { memory: '128Mi' },
                },
                volumeMounts: [
                  { name: 'rclone-config', mountPath: '/config', readOnly: true },
                  { name: 'work', mountPath: '/work' },
                ],
              },
              (container) {
                name: 'render-config',
                image: 'ghcr.io/hairyhenderson/gomplate:v4.3.3-alpine',
                command: ['gomplate'],
                args: ['-f', '/template/configmap.yaml.tmpl', '-o', '/work/configmap.yaml'],
                resources: {
                  requests: { cpu: '10m', memory: '32Mi' },
                  limits: { memory: '64Mi' },
                },
                volumeMounts: [
                  { name: 'config-template', mountPath: '/template', readOnly: true },
                  { name: 'work', mountPath: '/work' },
                ],
              },
              (container) {
                name: 'apply-config',
                image: 'registry.k8s.io/kubectl:v1.36.4',
                command: ['kubectl'],
                args: ['apply', '-f', '/work/configmap.yaml', '--namespace=' + app.namespace],
                resources: {
                  requests: { cpu: '10m', memory: '32Mi' },
                  limits: { memory: '128Mi' },
                },
                volumeMounts: [
                  { name: 'work', mountPath: '/work', readOnly: true },
                ],
              },
            ],
            containers: [
              (container) {
                name: 'rollout-restart',
                image: 'registry.k8s.io/kubectl:v1.36.4',
                command: ['kubectl'],
                args: [
                  'rollout',
                  'restart',
                  'deployment/' + deployment.metadata.name,
                  '--namespace=' + app.namespace,
                ],
                resources: {
                  requests: { cpu: '10m', memory: '32Mi' },
                  limits: { memory: '128Mi' },
                },
              },
            ],
            volumes: [
              { name: 'rclone-config', configMap: { name: rcloneConfig.metadata.name } },
              { name: 'config-template', configMap: { name: configTemplate.metadata.name } },
              { name: 'work', emptyDir: {} },
            ] + s3Irsa.volumes,
          },
        },
      },
    },
  },
}
