local app = import 'app.json5';

{
  apiVersion: 'v1',
  kind: 'LimitRange',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    limits: [
      {
        type: 'Container',
        default: {
          cpu: '100m',
          memory: '128Mi',
        },
        defaultRequest: {
          cpu: '50m',
          memory: '64Mi',
        },
        max: {
          cpu: '8',
          memory: '16Gi',
        },
      },
      {
        type: 'PersistentVolumeClaim',
        max: {
          storage: '128Gi',
        },
      },
    ],
  },
}
