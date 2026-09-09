local labels = import '../../components/labels.libsonnet';
local storage = import '../../components/storage.libsonnet';
{
  apiVersion: 'valkey.io/v1alpha1',
  kind: 'ValkeyCluster',
  metadata: {
    name: 'argocd-valkey',
    namespace: 'argocd',
    annotations: {
      'argocd.argoproj.io/sync-options': 'SkipDryRunOnMissingResource=true',
    },
    labels: labels('argocd-valkey'),
  },
  spec: {
    shards: 1,
    replicas: 0,
    scheduling: {
      affinity: storage.avoidSlowNodeAffinity,
    },
    resources: {
      requests: {
        cpu: '5m',
        memory: '16Mi',
      },
      limits: {
        cpu: '100m',
        memory: '256Mi',
      },
    },
    config: {
      'maxmemory-policy': 'noeviction',
    },
  },
}
