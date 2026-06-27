local container = import '../../components/container.libsonnet';
local labels = import '../../components/labels.libsonnet';
local localBundle = import '../clusterissuer/local-bundle.jsonnet';
local app = import 'app.json5';
local configmapAws = import 'configmap-aws.jsonnet';
local configmapRclone = import 'configmap-rclone.jsonnet';
local configmapScript = import 'configmap-script.jsonnet';
local externalSecretAws = import 'external-secret-aws.jsonnet';
local sa = import 'sa.jsonnet';
{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (labels)(app.name),
  },
  spec: {
    schedule: '10 2 * * *',  // AM 2:10
    timeZone: 'Asia/Tokyo',
    concurrencyPolicy: 'Forbid',
    startingDeadlineSeconds: 120,
    jobTemplate: {
      spec: {
        template: {
          metadata: {
            labels: (labels)(app.name),
          },
          spec: {
            serviceAccountName: sa.metadata.name,
            restartPolicy: 'OnFailure',
            containers: [
              std.mergePatch(
                (container) {
                  name: 'rclone',
                  image: 'public.ecr.aws/aws-cli/aws-cli:2.35.8',
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
                      subPath: 'usr/local/bin',
                    },
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
                name: 'minio-default-sts-token',
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
                  name: localBundle.metadata.name,
                },
              },
              {
                name: 'rclone-config',
                configMap: {
                  name: configmapRclone.metadata.name,
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
                  name: configmapAws.metadata.name,
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
                  secretName: externalSecretAws.spec.target.name,
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
                  name: configmapScript.metadata.name,
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
