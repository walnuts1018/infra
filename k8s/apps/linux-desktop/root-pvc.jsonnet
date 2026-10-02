local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: app.name + '-root',
    namespace: app.namespace,
    labels: labels(app.name),
    annotations: {
      'argocd.argoproj.io/sync-options': 'Prune=false',
      'argocd.argoproj.io/sync-wave': '-2',
    },
  },
  spec: {
    storageClassName: 'local-path',
    accessModes: [
      'ReadWriteOnce',
    ],
    resources: {
      requests: {
        storage: '64Gi',
      },
    },
  },
}
