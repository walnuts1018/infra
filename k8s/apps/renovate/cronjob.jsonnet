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
                image: 'debian:13.5-slim',
                command: [
                  'sh',
                  '-c',
                  'findmnt /tmp/renovate -n -o USE% | awk \'{if( int($1) > 75 ){ system("rm -rf /tmp/renovate/cache") }}\'',
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
              (container) {
                name: 'renovate',
                image: 'ghcr.io/renovatebot/renovate:43.263.6',
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
                  // {
                  //   name: 'LOG_LEVEL',
                  //   value: 'debug',
                  // },
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
                ],
                volumeMounts: [
                  {
                    name: 'renovate',
                    mountPath: '/tmp/renovate',
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
                name: 'renovate',
                persistentVolumeClaim: {
                  claimName: 'renovate',
                },
              },
              {
                name: 'config',
                configMap: {
                  name: (import 'configmap-config.jsonnet').metadata.name,
                },
              },
            ],
          },
        },
      },
    },
  },
}
