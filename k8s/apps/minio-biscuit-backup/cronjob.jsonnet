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
            labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
          },
          spec: {
            serviceAccountName: (import 'sa.jsonnet').metadata.name,
            restartPolicy: 'OnFailure',
            initContainers: [
              (import '../../components/container.libsonnet') {
                name: 'copy-rclone',
                image: 'ghcr.io/rclone/rclone:1.72.1',
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
                image: 'ghcr.io/hairyhenderson/gomplate:v4.3.3-alpine',
                command: [
                  '/bin/sh',
                  '-c',
                ],
                args: [
                  'export PATH=$PATH:/rclone && ash /scripts/inject-secret-to-config.sh /template/rclone.conf.template /config/rclone.conf',
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
                    memory: '256Mi',
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
              }, {
                securityContext: {
                  capabilities: null,
                  readOnlyRootFilesystem: false,
                },
              }),
            ],
            containers: [
              std.mergePatch(
                (import '../../components/container.libsonnet') {
                  name: 'backuper',
                  image: 'public.ecr.aws/aws-cli/aws-cli:2.32.31',
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
                  ports: [
                    {
                      name: 'metrics',
                      containerPort: 9250,
                    },
                  ],
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
                    {
                      name: 'minio-biscuit-sts-token',
                      mountPath: '/var/run/secrets/sts.min.io/serviceaccount',
                      readOnly: true,
                    },
                    {
                      name: 'local-ca-bundle',
                      mountPath: '/etc/ssl/certs/trust-bundle.pem',
                      subPath: 'trust-bundle.pem',
                      readOnly: true,
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
                name: 'minio-biscuit-sts-token',
                projected: {
                  sources: [
                    {
                      serviceAccountToken: {
                        audience: 'sts.min.io',
                        path: 'token',
                      },
                    },
                  ],
                },
              },
              {
                name: 'local-ca-bundle',
                configMap: {
                  name: (import '../clusterissuer/local-bundle.jsonnet').metadata.name,
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
