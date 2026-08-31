local labels = import '../../components/labels.libsonnet';
local storage = import '../../components/storage.libsonnet';
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
      name: (import 'keepercluster.jsonnet').metadata.name,
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
    podTemplate: {
      affinity: storage.avoidSlowNodeAffinity,
    },
    containerTemplate: {
      resources: {
        requests: {
          cpu: '130m',
          memory: '1Gi',
        },
        limits: {
          memory: '4Gi',
        },
      },
    },
  },
}
