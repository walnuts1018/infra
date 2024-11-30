{
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: 'affine-storage',
  },
  spec: {
    storageClassName: 'longhorn',
    volumeName: 'affine-storage',
    accessModes: [
      'ReadWriteOnce',
    ],
    resources: {
      requests: {
        storage: '4Gi',
      },
    },
  },
}
