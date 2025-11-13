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
            initContainers: [
              (import '../../components/container.libsonnet') {
                name: 'copy-rclone',
                image: 'ghcr.io/rclone/rclone:1.71.2',
                command: [
                  '/bin/sh',
                  '-c',
                ],
                args: [
                  'cp /usr/local/bin/rclone /rclone/rclone',
                ],
                resources: {
                  requests: {
                    cpu: '1m',
                    memory: '10Mi',
                  },
                  limits: {
                    cpu: '100m',
                    memory: '128Mi',
                  },
                },
                volumeMounts: [
                  {
                    name: 'rclone',
                    mountPath: '/rclone',
                  },
                ],
              },
              std.mergePatch((import '../../components/container.libsonnet') {
                name: 'inject-secret-to-config',
                  image: 'debian:13.1-slim',
                command: [
                  '/bin/sh',
                  '-c',
                ],
                args: [
                  'export PATH=$PATH:/rclone &&bash /scripts/inject-secret-to-config.sh /template/rclone.conf.template /config/rclone.conf',
                ],
                envFrom: [
                  {
                    secretRef: {
                      name: (import 'external-secret-b2.jsonnet').spec.target.name,
                    },
                  },
                ],
                resources: {
                  requests: {
                    cpu: '1m',
                    memory: '10Mi',
                  },
                  limits: {
                    cpu: '100m',
                    memory: '128Mi',
                  },
                },
                volumeMounts: [
                  {
                    name: 'rclone',
                    mountPath: '/rclone',
                    readOnly: true,
                  },
                  {
                    name: 'rclone-config-template',
                    mountPath: '/template',
                    readOnly: true,
                  },
                  {
                    name: 'rclone-config',
                    mountPath: '/config',
                  },
                  {
                    name: 'scripts',
                    mountPath: '/scripts',
                    readOnly: true,
                  },
                ],
              },{
                securityContext: {
                  readOnlyRootFilesystem: false,
                },
              })
            ],
            containers: [
              std.mergePatch(
                (import '../../components/container.libsonnet') {
                  name: 'backuper',
                  image: 'public.ecr.aws/aws-cli/aws-cli:2.31.34',
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
                      readOnly: true,
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
                      mountPath: '/config',
                      readOnly: true,
                    },
                    {
                      name: 'scripts',
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
                emptyDir: {},
              },
              {
                name: 'rclone-config',
                emptyDir: {},
              },
              {
                name: 'rclone-config-template',
                configMap: {
                  name: (import 'configmap-rclone.jsonnet').metadata.name,
                  items: [
                    {
                      key: 'rclone.conf.template',
                      path: 'rclone.conf.template',
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
                name: 'scripts',
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
