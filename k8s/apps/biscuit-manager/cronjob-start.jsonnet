{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: (import 'app.json5').name,
  },
  spec: {
    schedule: '0 2 * * *',  // AM 2:00
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
              std.mergePatch((import '../../components/container.libsonnet') {
                name: 'biscuit-manager',
                image: 'debian:13.1-slim',
                command: [
                  'bash',
                  '/start.sh',
                ],
                resources: {
                  requests: {
                    cpu: '10m',
                    memory: '10Mi',
                  },
                  limits: {
                    cpu: '1',
                    memory: '100Mi',
                  },
                },
                volumeMounts: [
                  {
                    name: 'start-script',
                    mountPath: '/start.sh',
                    readOnly: true,
                    subPath: 'start.sh',
                  },
                ],
              }, {}),
            ],
            volumes: [
              {
                name: 'start-script',
                configMap: {
                  name: (import 'configmap.jsonnet').metadata.name,
                  items: [
                    {
                      key: 'start.sh',
                      path: 'start.sh',
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
