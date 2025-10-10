{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: (import 'app.json5').name + '-shutdown',
  },
  spec: {
    schedule: '0 6 * * *',  // AM 6:00
    timeZone: 'Asia/Tokyo',
    concurrencyPolicy: 'Forbid',
    startingDeadlineSeconds: 120,
    jobTemplate: {
      spec: {
        template: {
          spec: {
            serviceAccountName: (import 'sa.jsonnet').metadata.name,
            hostNetwork: true,
            restartPolicy: 'OnFailure',
            containers: [
              std.mergePatch(
                (import '../../components/container.libsonnet') {
                  name: 'biscuit-manager',
                  image: 'debian:13.1-slim',
                  command: [
                    'bash',
                    '/shutdown.sh',
                  ],
                  resources: {
                    requests: {
                      cpu: '10m',
                      memory: '10Mi',
                    },
                    limits: {
                      cpu: '1',
                      memory: '512Mi',
                    },
                  },
                  securityContext:: null,
                  volumeMounts: [
                    {
                      name: 'shutdown-script',
                      mountPath: '/shutdown.sh',
                      readOnly: true,
                      subPath: 'shutdown.sh',
                    },
                    {
                      name: 'shutdown-manager-token',
                      mountPath: '/var/run/secrets/shutdown-manager.local.walnuts.dev/serviceaccount',
                      readOnly: true,
                    },
                    {
                      name: 'tmp',
                      mountPath: '/tmp',
                    },
                  ],
                }, {}
              ),
            ],
            volumes: [
              {
                name: 'shutdown-script',
                configMap: {
                  name: (import 'configmap.jsonnet').metadata.name,
                  items: [
                    {
                      key: 'shutdown.sh',
                      path: 'shutdown.sh',
                    },
                  ],
                },
              },
              {
                name: 'shutdown-manager-token',
                projected: {
                  sources: [
                    {
                      serviceAccountToken: {
                        audience: 'shutdown-manager.local.walnuts.dev',
                        expirationSeconds: 86400,
                        path: 'token',
                      },
                    },
                  ],
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
