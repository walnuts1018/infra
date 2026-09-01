local container = import '../../components/container.libsonnet';
local app = import 'app.json5';
local rcloneConfig = import 'configmap-rclone.jsonnet';
local deployment = import 'deployment.jsonnet';
local s3Irsa = import 's3-irsa.libsonnet';
local updaterSa = import 'updater-sa.jsonnet';

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
            ] + s3Irsa.volumes,
          },
        },
      },
    },
  },
}
