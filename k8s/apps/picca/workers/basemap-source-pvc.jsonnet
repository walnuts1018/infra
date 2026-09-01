local app = import '../app.json5';
{
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: app.name + '-basemap-source',
    namespace: app.namespace,
  },
  spec: {
    storageClassName: 'local-path',
    accessModes: [
      'ReadWriteOnce',
    ],
    resources: {
      requests: {
        storage: '150Gi',
      },
    },
  },
}
