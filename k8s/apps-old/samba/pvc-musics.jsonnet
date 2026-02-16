{
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: 'musics',
  },
  spec: {
    storageClassName: 'longhorn',
    accessModes: [
      'ReadWriteOnce',
    ],
    resources: {
      requests: {
        storage: '32Gi',
      },
    },
  },
}
