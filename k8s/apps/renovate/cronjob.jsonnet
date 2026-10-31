local container = import '../../components/container.libsonnet';
local app = import 'app.json5';
local externalSecret = import 'external-secret.jsonnet';
{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (import '../../components/labels.libsonnet')(app.name),
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
              (container) {
                name: 'disk-cleaner',
                image: 'debian:13.7-slim@sha256:f6b08b09a05725f9431502d3b5714f5c4576e82c1a84fa1debe0c24a7e0c3ec4',
                command: [
                  'sh',
                  '/scripts/disk-cleaner.sh',
                ],
                volumeMounts: [
                  {
                    name: 'renovate-cache',
                    mountPath: '/tmp/renovate/cache',
                  },
                  {
                    name: 'scripts',
                    mountPath: '/scripts',
                    readOnly: true,
                  },
                ],
                securityContext: {
                  runAsUser: 0,
                },
              },
            ],
            containers: [
              (container) {
                name: 'renovate',
                image: 'ghcr.io/renovatebot/renovate:44.164.10@sha256:a1a928e6680df73474a2408620374bfd397a38b7adbc74d4d5ffe4c7a03e3c2b',
                resources: {
                  requests: {
                    cpu: '1',
                    memory: '2Gi',
                  },
                  limits: {
                    cpu: '1.5',
                    memory: '8Gi',
                  },
                },
                local branch_prefix = 'renovate/',
                env: [
                  {
                    name: 'LOG_LEVEL',
                    value: 'debug',
                  },
                  {
                    name: 'RENOVATE_PLATFORM',
                    value: 'github',
                  },
                  {
                    name: 'RENOVATE_CONFIG_FILE',
                    value: '/config/config.js',
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
                    name: 'RENOVATE_IGNORE_PR_AUTHOR',
                    value: 'true',
                  },
                  {
                    name: 'GITHUB_APP_ID',
                    valueFrom: {
                      secretKeyRef: {
                        name: externalSecret.spec.target.name,
                        key: 'github-app-id',
                      },
                    },
                  },
                  {
                    name: 'GITHUB_APP_INSTALLATION_ID',
                    valueFrom: {
                      secretKeyRef: {
                        name: externalSecret.spec.target.name,
                        key: 'github-app-installation-id',
                      },
                    },
                  },
                  {
                    name: 'GITHUB_APP_PRIVATE_KEY',
                    valueFrom: {
                      secretKeyRef: {
                        name: externalSecret.spec.target.name,
                        key: 'github-app-private-key',
                      },
                    },
                  },
                  {
                    name: 'GHCR_TOKEN',
                    valueFrom: {
                      secretKeyRef: {
                        name: externalSecret.spec.target.name,
                        key: 'pat-for-ghcr',
                        optional: true,
                      },
                    },
                  },
                ],
                volumeMounts: [
                  {
                    name: 'renovate-work',
                    mountPath: '/tmp/renovate',
                  },
                  {
                    name: 'renovate-cache',
                    mountPath: '/cache',
                  },
                  {
                    name: 'config',
                    mountPath: '/config',
                    readOnly: true,
                  },
                ],
              },
            ],
            tolerations: [
              {
                key: 'node.walnuts.dev/untrusted',
                operator: 'Exists',
              },
            ],
            volumes: [
              {
                name: 'renovate-work',
                emptyDir: {},
              },
              {
                name: 'renovate-cache',
                persistentVolumeClaim: {
                  claimName: (import 'pvc.jsonnet').metadata.name,
                },
              },
              {
                name: 'config',
                configMap: {
                  name: (import 'configmap-config.jsonnet').metadata.name,
                },
              },
              {
                name: 'scripts',
                configMap: {
                  name: (import 'configmap-scripts.jsonnet').metadata.name,
                },
              },
            ],
          },
        },
      },
    },
  },
}
