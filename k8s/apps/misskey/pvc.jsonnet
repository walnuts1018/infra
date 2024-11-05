{
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: (import 'app.json5').name,
  },
  spec: {
    storageClassName: 'longhorn',
    volumeName: 'misskey',
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
