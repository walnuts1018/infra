{
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: 'mega',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    storageClassName: 'longhorn-local-encrypted',
    accessModes: [
      'ReadWriteOnce',
    ],
    resources: {
      requests: {
        storage: '142Gi',
      },
    },
  },
}
