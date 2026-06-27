local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'PersistentVolume',
  metadata: {
    name: app.name + '-pv',
    labels: (import '../../components/labels.libsonnet')(app.name),
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
