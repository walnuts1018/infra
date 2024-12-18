{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  spec: {
    schedule: '*/10 * * * *',
    concurrencyPolicy: 'Forbid',
    jobTemplate: {
      spec: {
        template: {
          spec: {
            restartPolicy: 'Never',
            containers: [
              {
                name: 'renovate',
                image: 'renovate/renovate:39.72.5',
                resources: {
                  requests: {
                    memory: '100Mi',
                  },
                  limits: {
                    memory: '512Mi',
                  },
                },
                env: [
                  {
                    name: 'LOG_LEVEL',
                    value: 'debug',
                  },
                  {
                    name: 'RENOVATE_AUTODISCOVER',
                    value: 'true',
                  },
                  {
                    name: 'RENOVATE_AUTODISCOVER_FILTER',
                    value: 'walnuts1018/*',
                  },
                  {
                    name: 'RENOVATE_TOKEN',
                    valueFrom: {
                      secretKeyRef: {
                        name: (import 'external-secret.jsonnet').spec.target.name,
                        key: 'github-token',
                      },
                    },
                  },
                ],
                volumeMounts: [
                  {
                    name: 'renovate',
                    mountPath: '/tmp/renovate',
                  },
                ],
              },
            ],
            volumes: [
              {
                name: 'renovate',
                persistentVolumeClaim: {
                  claimName: 'renovate',
                },
              },
            ],
          },
        },
      },
    },
  },
}
