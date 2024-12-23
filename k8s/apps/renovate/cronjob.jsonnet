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
            securityContext: {
              fsGroup: 12021,
              fsGroupChangePolicy: 'OnRootMismatch',
            },
            restartPolicy: 'Never',
            containers: [
              {
                name: 'renovate',
                image: 'renovate/renovate:39.82.2',
                resources: {
                  requests: {
                    memory: '256Mi',
                  },
                  limits: {
                    memory: '2Gi',
                  },
                },
                local branch_prefix = 'rennovate/',
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
                    value: 'walnuts1018/infra',
                  },
                  {
                    name: 'RENOVATE_BRANCH_PREFIX',
                    value: branch_prefix,
                  },
                  {
                    name: 'RENOVATE_BRANCH_PREFIX_OLD',
                    value: branch_prefix,
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
