local container = import '../../components/container.libsonnet';
local labels = import '../../components/labels.libsonnet';
local localBundle = import '../clusterissuer/local-bundle.jsonnet';
local app = import 'app.json5';
local configmapAws = import 'configmap-aws.jsonnet';
local configmapRclone = import 'configmap-rclone.jsonnet';
local configmapScript = import 'configmap-script.jsonnet';
local externalSecretB2 = import 'external-secret-b2.jsonnet';
local sa = import 'sa.jsonnet';
{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: app.name,
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
            labels: (labels)(app.name),
          },
          spec: {
            serviceAccountName: sa.metadata.name,
            restartPolicy: 'OnFailure',
            initContainers: [
              (container) {
                name: 'copy-rclone',
                image: 'ghcr.io/rclone/rclone:1.74.3',
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
              std.mergePatch((container) {
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
                      name: externalSecretB2.spec.target.name,
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
                (container) {
                  name: 'backuper',
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
                  name: configmapRclone.metadata.name,
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
                  name: localBundle.metadata.name,
                },
              },
              {
                name: 'scripts',
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
