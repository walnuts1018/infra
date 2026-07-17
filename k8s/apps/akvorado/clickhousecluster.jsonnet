local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'clickhouse.com/v1alpha1',
  kind: 'ClickHouseCluster',
  metadata: {
    name: 'akvorado-clickhouse',
    namespace: app.namespace,
    annotations: {
      'argocd.argoproj.io/sync-options': 'SkipDryRunOnMissingResource=true',
    },
    labels: labels('akvorado-clickhouse'),
  },
  spec: {
    keeperClusterRef: {
      name: 'akvorado-keeper',
    },
    replicas: 1,
    dataVolumeClaimSpec: {
      accessModes: ['ReadWriteOnce'],
      resources: {
        requests: {
          storage: '32Gi',
        },
      },
    },
    containerTemplate: {
      resources: {
        requests: {
          cpu: '116m',
          memory: '593Mi',
        },
        limits: {
          cpu: '2',
          memory: '4Gi',
        },
      },
    },
  },
}
