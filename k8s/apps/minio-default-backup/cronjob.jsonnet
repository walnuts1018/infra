{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: (import 'app.json5').name,
  },
  spec: {
    schedule: '10 3 * * *',  // AM 3:10
    timeZone: 'Asia/Tokyo',
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
                  image: 'ghcr.io/rclone/rclone:1.71.1',
                  command: [
                    // '/bin/ash',
                    // '/scripts/backup.sh',
                    'sleep',
                    'infinity',
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
                      name: 'minio-default-sts-token',
                      mountPath: '/var/run/secrets/sts.min.io/serviceaccount',
                      readOnly: true,
                    },
                    {
                      name: 'local-ca-bundle',
                      mountPath: '/etc/ssl/certs/trust-bundle.pem',
                      subPath: 'trust-bundle.pem',
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
                      mountPath: '/config/rclone.conf',
                      readOnly: true,
                      subPath: 'rclone.conf',
                    },
                    {
                      name: 'backup-script',
                      mountPath: '/scripts/backup.sh',
                      readOnly: true,
                      subPath: 'backup.sh',
                    },
                    {
                      name: 'tmp',
                      mountPath: '/tmp',
                    },
                    {
                      name: 'aws-cli',
                      mountPath: '/aws-cli',
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
                name: 'minio-default-sts-token',
                projected: {
                  sources: [
                    {
                      serviceAccountToken: {
                        audience: 'sts.min.io',
                        expirationSeconds: 86400,
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
                name: 'rclone-config',
                configMap: {
                  name: (import 'configmap-rclone.jsonnet').metadata.name,
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
                  items: [
                    {
                      key: 'backup.sh',
                      path: 'backup.sh',
                    },
                  ],
                },
              },
              {
                name: 'tmp',
                emptyDir: {},
              },
              {
                name: 'aws-cli',
                image: {
                  reference: 'public.ecr.aws/aws-cli/aws-cli:2.31.13',
                },
              },
            ],
          },
        },
      },
    },
  },
}
