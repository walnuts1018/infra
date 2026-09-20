local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: app.name + '-storage',
    namespace: app.namespace,
  },
  spec: {
    accessModes: ['ReadWriteOnce'],
    storageClassName: 'longhorn',
    resources: {
      requests: {
        storage: '16Gi',
      },
    },
  },
}
