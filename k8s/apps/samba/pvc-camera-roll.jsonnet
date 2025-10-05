{
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: 'camera-roll',
  },
  spec: {
    storageClassName: 'longhorn',
    accessModes: [
      'ReadWriteOnce',
    ],
    resources: {
      requests: {
        storage: '100Gi',
      },
    },
  },
}
