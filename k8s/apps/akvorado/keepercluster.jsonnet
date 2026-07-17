local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'clickhouse.com/v1alpha1',
  kind: 'KeeperCluster',
  metadata: {
    name: 'akvorado-keeper',
    namespace: app.namespace,
    annotations: {
      'argocd.argoproj.io/sync-options': 'SkipDryRunOnMissingResource=true',
    },
    labels: labels('akvorado-keeper'),
  },
  spec: {
    replicas: 1,
    dataVolumeClaimSpec: {
      accessModes: ['ReadWriteOnce'],
      resources: {
        requests: {
          storage: '5Gi',
        },
      },
    },
  },
}
