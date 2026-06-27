local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: 'mega',
    namespace: app.namespace,
  },
  spec: {
    storageClassName: 'longhorn-single-encrypted',
    accessModes: [
      'ReadWriteOnce',
    ],
    resources: {
      requests: {
        storage: '176Gi',
      },
    },
  },
}
