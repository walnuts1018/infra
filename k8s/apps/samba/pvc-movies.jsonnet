{
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: 'movies',
  },
  spec: {
    storageClassName: 'longhorn-single',
    accessModes: [
      'ReadWriteOnce',
    ],
    resources: {
      requests: {
        storage: '248Gi',
      },
    },
  },
}
