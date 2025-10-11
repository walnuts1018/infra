{
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: 'root',
  },
  spec: {
    storageClassName: 'longhorn',
    accessModes: [
      'ReadWriteOnce',
    ],
    resources: {
      requests: {
        storage: '64Gi',
      },
    },
  },
}
