local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'valkey.io/v1alpha1',
  kind: 'ValkeyCluster',
  metadata: {
    name: 'akvorado-valkey',
    namespace: app.namespace,
    annotations: {
      'argocd.argoproj.io/sync-options': 'SkipDryRunOnMissingResource=true',
    },
    labels: labels('akvorado-valkey'),
  },
  spec: {
    shards: 1,
    replicas: 1,
    persistence: {
      size: '1Gi',
    },
    resources: {
      requests: {
        cpu: '6m',
        memory: '13Mi',
      },
      limits: {
        cpu: '500m',
        memory: '256Mi',
      },
    },
  },
}
