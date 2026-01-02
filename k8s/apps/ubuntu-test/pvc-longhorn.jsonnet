{
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: 'longhorn',
  },
  spec: {
    storageClassName: 'longhorn-local',
    accessModes: [
      'ReadWriteOnce',
    ],
    resources: {
      requests: {
        storage: '16Gi',
      },
    },
  },
}
