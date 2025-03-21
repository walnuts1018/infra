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
    startingDeadlineSeconds: 12000,
    jobTemplate: {
      spec: {
        template: {
          spec: {
            restartPolicy: 'OnFailure',
            containers: [
              {
                name: 'photoprism',
                image: 'photoprism/photoprism:250321',
                command: [
                  'photoprism',
                  'index',
                  '--cleanup',
                ],
                resources: {
                  requests: {
                    cpu: '10m',
                    memory: '2Gi',
                  },
                  limits: {
                    cpu: '2',
                    memory: '4Gi',
                  },
                },
                env: [
                  {
                    name: 'PHOTOPRISM_ORIGINALS_LIMIT',
                    value: '-1',
                  },
                  {
                    name: 'PHOTOPRISM_DETECT_NSFW',
                    value: 'true',
                  },
                  {
                    name: 'PHOTOPRISM_DATABASE_DRIVER',
                    value: 'mysql',
                  },
                  {
                    name: 'PHOTOPRISM_HTTP_HOST',
                    value: '0.0.0.0',
                  },
                  {
                    name: 'PHOTOPRISM_HTTP_PORT',
                    value: '2342',
                  },
                  {
                    name: 'PHOTOPRISM_ADMIN_USER',
                    value: 'photoprism',
                  },
                ],
                envFrom: [
                  {
                    secretRef: {
                      name: (import 'external-secret.jsonnet').spec.target.name,
                      optional: false,
                    },
                  },
                ],
                ports: [
                  {
                    containerPort: 2342,
                    name: 'http',
                  },
                ],
                volumeMounts: [
                  {
                    mountPath: '/photoprism/originals',
                    name: 'originals',
                  },
                  {
                    mountPath: '/photoprism/import',
                    name: 'import',
                  },
                  {
                    mountPath: '/photoprism/storage',
                    name: 'storage',
                  },
                  {
                    mountPath: '/photoprism/storage/cache',
                    name: 'cache',
                  },
                ],
              },
            ],
            volumes: [
              {
                name: 'originals',
                hostPath: {
                  path: '/mnt/data/share/CameraRoll',
                  type: 'Directory',
                },
              },
              {
                name: 'import',
                persistentVolumeClaim: {
                  claimName: 'photoprism-import',
                },
              },
              {
                name: 'cache',
                persistentVolumeClaim: {
                  claimName: 'photoprism-cache',
                },
              },
              {
                name: 'storage',
                persistentVolumeClaim: {
                  claimName: 'photoprism-storage',
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
