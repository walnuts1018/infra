{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  spec: {
    schedule: '*/5 * * * *',
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
            initContainers: [
              (import '../../components/container.libsonnet') {
                name: 'disk-cleaner',
                image: 'debian:12.10-slim',
                command: [
                  'sh',
                  '-c',
                  'df --output=target,pcent | awk \'{if( $1 == "/tmp/renovate" && $2 > 75 ){ system("rm -rf /tmp/renovate/cache") }}\'',
                ],
                volumeMounts: [
                  {
                    name: 'renovate',
                    mountPath: '/tmp/renovate',
                  },
                ],
                securityContext: {
                  runAsUser: 0,
                },
              },
            ],
            containers: [
              (import '../../components/container.libsonnet') {
                name: 'renovate',
                image: 'ghcr.io/renovatebot/renovate:39.213.6',
                resources: {
                  requests: {
                    cpu: '500m',
                    memory: '256Mi',
                  },
                  limits: {
                    cpu: '500m',
                    memory: '2Gi',
                  },
                },
                local branch_prefix = 'renovate/',
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
                    name: 'RENOVATE_GIT_AUTHOR',
                    value: 'renovate[bot] <renovate[bot]@users.noreply.github.com>',
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
