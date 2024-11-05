{
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: 'photoprism-mariadb',
  },
  spec: {
    storageClassName: 'longhorn',
    volumeName: 'photoprism-mariadb',
    accessModes: [
      'ReadWriteOnce',
    ],
    resources: {
      requests: {
        storage: '8Gi',
      },
    },
  },
}
