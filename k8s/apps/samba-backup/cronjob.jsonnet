{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: (import 'app.json5').name,
  },
  spec: {
    schedule: '0 3 * * *',
    timeZone: 'Asia/Tokyo',
    concurrencyPolicy: 'Forbid',
    startingDeadlineSeconds: 120,
    jobTemplate: {
      spec: {
        template: {
          spec: {
            restartPolicy: 'OnFailure',
            containers: [
              std.mergePatch((import '../../components/container.libsonnet') {
                name: 'samba-backup',
                image: 'debian:13.0',
                command: [
                  'sh',
                  '/backup.sh',
                ],
                env: [
                  {
                    name: 'SAMBA_USER',
                    valueFrom: {
                      secretKeyRef: {
                        name: (import 'external-secret.jsonnet').spec.target.name,
                        key: 'user',
                      },
                    },
                  },
                  {
                    name: 'SAMBA_PASSWORD',
                    valueFrom: {
                      secretKeyRef: {
                        name: (import 'external-secret.jsonnet').spec.target.name,
                        key: 'password',
                      },
                    },
                  },
                ],
                readinessProbe: {
                  exec: {
                    command: [
                      'cat',
                      '/tmp/healthy',
                    ],
                  },
                },
                resources: {
                  requests: {
                    cpu: '10m',
                    memory: '217Mi',
                  },
                  limits: {
                    cpu: '1',
                    memory: '10Gi',
                  },
                },
                volumeMounts: [
                  {
                    name: 'samba-backup-script',
                    mountPath: '/backup.sh',
                    readOnly: true,
                    subPath: 'backup.sh',
                  },
                  {
                    name: 'samba-local-dir',
                    mountPath: '/samba-share',
                  },
                  {
                    name: 'samba-backup',
                    mountPath: '/samba-backup',
                  },
                  {
                    name: 'samba-id-ed25519',
                    mountPath: '/root/.ssh/id_ed25519',
                    subPath: 'id_ed25519',
                  },
                ],
              }, {
                securityContext: {
                  readOnlyRootFilesystem: false,
                  privileged: true,
                },
              }),
            ],
            volumes: [
              {
                name: 'samba-backup-script',
                configMap: {
                  name: (import 'configmap.jsonnet').metadata.name,
                  items: [
                    {
                      key: 'backup.sh',
                      path: 'backup.sh',
                    },
                  ],
                },
              },
              {
                name: 'samba-local-dir',
                hostPath: {
                  path: '/mnt/data/share',
                  type: 'Directory',
                },
              },
              {
                name: 'samba-backup',
                emptyDir: {},
              },
              {
                name: 'samba-id-ed25519',
                secret: {
                  secretName: (import 'external-secret.jsonnet').spec.target.name,
                  defaultMode: std.parseOctal('0600'),
                },
              },
            ],
            nodeSelector: {
              'kubernetes.io/hostname': 'cake',
            },
          },
        },
      },
    },
  },
}
