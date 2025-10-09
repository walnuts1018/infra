{
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: 'movies',
  },
  spec: {
    storageClassName: 'longhorn-local',
    accessModes: [
      'ReadWriteOnce',
    ],
    resources: {
      requests: {
        storage: '230Gi',
      },
    },
  },
}
