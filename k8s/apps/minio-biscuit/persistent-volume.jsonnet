{
  apiVersion: 'v1',
  kind: 'PersistentVolume',
  metadata: {
    name: 'my-pv-hostpath',
  },
  spec: {
    storageClassName: 'manual-minio-hostpath',
    capacity: {
      storage: '32Gi',
    },
    accessModes: [
      'ReadWriteOnce',
    ],
    hostPath: {
      path: '/mnt/HDD-1TB/minio',
    },
  },
}
