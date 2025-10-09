{
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: 'books',
  },
  spec: {
    storageClassName: 'longhorn',
    accessModes: [
      'ReadWriteMany',
    ],
    resources: {
      requests: {
        storage: '34Gi',
      },
    },
  },
}
