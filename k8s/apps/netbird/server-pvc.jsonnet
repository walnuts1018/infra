local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: app.name + '-server',
    namespace: app.namespace,
  },
  spec: {
    accessModes: ['ReadWriteOnce'],
    storageClassName: 'longhorn',
    resources: {
      requests: {
        storage: '1Gi',
      },
    },
  },
}
