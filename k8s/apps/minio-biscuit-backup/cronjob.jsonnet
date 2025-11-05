{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: (import 'app.json5').name,
  },
  spec: {
    schedule: '10 3 * * *',  // 適当
    suspend: true,  // 手動起動のみ
    concurrencyPolicy: 'Forbid',
    startingDeadlineSeconds: 120,
    jobTemplate: {
      spec: {
        template: {
          metadata: {
            labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
          },
          spec: {
            serviceAccountName: (import 'sa.jsonnet').metadata.name,
            restartPolicy: 'OnFailure',
            containers: [
              std.mergePatch(
                (import '../../components/container.libsonnet') {
                  name: 'rclone',
                  image: 'public.ecr.aws/aws-cli/aws-cli:2.31.29',
                  command: [
                    '/usr/bin/bash',
                    '-c',
                  ],
                  args: [
                    'export PATH=$PATH:/rclone && bash /scripts/backup.sh',
                  ],
                  resources: {
                    requests: {
                      cpu: '10m',
                      memory: '10Mi',
                    },
                    limits: {
                      cpu: '1',
                      memory: '2Gi',
                    },
                  },
                  volumeMounts: [
                    {
                      name: 'rclone',
                      mountPath: '/rclone',
                      subPath: 'usr/local/bin',
                    },
                    {
                      name: 'aws-config',
                      mountPath: '/root/.aws/config',
                      readOnly: true,
                      subPath: 'config',
                    },
                    {
                      name: 'aws-credentials',
                      mountPath: '/root/.aws/credentials',
                      readOnly: true,
                      subPath: 'credentials',
                    },
                    {
                      name: 'rclone-config',
                      mountPath: '/config/rclone.conf',
                      readOnly: true,
                      subPath: 'rclone.conf',
                    },
                    {
                      name: 'backup-script',
                      mountPath: '/scripts',
                      readOnly: true,
                    },
                    {
                      name: 'tmp',
                      mountPath: '/tmp',
                    },
                  ],
                }, {
                  securityContext: {
                    readOnlyRootFilesystem: false,
                  },
                }
              ),
            ],
            volumes: [
              {
                name: 'rclone',
                image: {
                  reference: 'ghcr.io/rclone/rclone:1.71.1',
                },
              },
              {
                name: 'rclone-config',
                secret: {
                  serviceAccountTokename: (import 'external-secret-rclone.jsonnet').metadata.name,
                  items: [
                    {
                      key: 'rclone.conf',
                      path: 'rclone.conf',
                    },
                  ],
                },
              },
              {
                name: 'aws-config',
                configMap: {
                  name: (import 'configmap-aws.jsonnet').metadata.name,
                  items: [
                    {
                      key: 'config',
                      path: 'config',
                    },
                  ],
                },
              },
              {
                name: 'aws-credentials',
                secret: {
                  secretName: (import 'external-secret-aws.jsonnet').spec.target.name,
                  items: [
                    {
                      key: 'credentials',
                      path: 'credentials',
                    },
                  ],
                },
              },
              {
                name: 'backup-script',
                configMap: {
                  name: (import 'configmap-script.jsonnet').metadata.name,
                },
              },
              {
                name: 'tmp',
                emptyDir: {},
              },
            ],
          },
        },
      },
    },
  },
}
