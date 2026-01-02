{
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: 'localpath',
  },
  spec: {
    storageClassName: 'local-path',
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
