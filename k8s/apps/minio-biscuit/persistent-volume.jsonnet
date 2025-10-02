{
  apiVersion: 'v1',
  kind: 'PersistentVolume',
  metadata: {
    name: (import 'app.json5').name + '-pv',
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
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
