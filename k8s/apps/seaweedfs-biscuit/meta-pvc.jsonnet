local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: 'seaweedfs-meta',
    namespace: app.namespace,
    labels: labels(app.name) + {
      'app.kubernetes.io/component': 'mini',
    },
  },
  spec: {
    accessModes: ['ReadWriteOnce'],
    storageClassName: 'topolvm-ssd',
    volumeMode: 'Filesystem',
    resources: {
      requests: {
        storage: '20Gi',
      },
    },
  },
}
