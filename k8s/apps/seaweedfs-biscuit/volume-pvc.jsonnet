local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: 'seaweedfs-volume',
    namespace: app.namespace,
    labels: labels(app.name) + {
      'app.kubernetes.io/component': 'mini',
    },
  },
  spec: {
    accessModes: ['ReadWriteOnce'],
    storageClassName: 'topolvm-hdd',
    volumeMode: 'Filesystem',
    resources: {
      requests: {
        storage: '800Gi',
      },
    },
  },
}
