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
            initContainers: [
              std.mergePatch(
                (import '../../components/container.libsonnet'),
                {
                  name: 'wait-minio-default-backup',
                  image: 'registry.k8s.io/kubectl:v1.34.1',
                  command: [
                    '/usr/bin/bash',
                    '-c',
                  ],
                  args: [
                    'bash /scripts/wait_minio-default-backup.sh',
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
                      name: 'scripts',
                      mountPath: '/scripts',
                      readOnly: true,
                    },
                    {
                      name: 'tmp',
                      mountPath: '/tmp',
                    },
                  ],
                },
                {
                  securityContext: {
                    readOnlyRootFilesystem: false,
                  },
                }
              ),
            ],
            containers: [
              std.mergePatch(
                (import '../../components/container.libsonnet') {
                  name: 'trigger-and-wait-minio-biscuit-backup',
                  image: 'registry.k8s.io/kubectl:v1.34.1',
                  command: [
                    '/usr/bin/bash',
                    '-c',
                  ],
                  args: [
                    'bash /scripts/trigger_and_wait_minio-biscuit-backup.sh',
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
                      name: 'scripts',
                      mountPath: '/scripts',
                      readOnly: true,
                    },
                    {
                      name: 'tmp',
                      mountPath: '/tmp',
                    },
                    {
                      name: 'sa-token',
                      mountPath: '/var/run/secrets/kurumi.k8s.walnuts.dev/serviceaccount',
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
                name: 'scripts',
                configMap: {
                  name: (import 'configmap-script.jsonnet').metadata.name,
                },
              },
              {
                name: 'tmp',
                emptyDir: {},
              },
              {
                name: 'sa-token',
                projected: {
                  sources: [
                    {
                      serviceAccountToken: {
                        audience: 'kurumi.k8s.walnuts.dev',
                        expirationSeconds: 86400,
                        path: 'token',
                      },
                    },
                  ],
                },
              },
            ],
          },
        },
      },
    },
  },
}
