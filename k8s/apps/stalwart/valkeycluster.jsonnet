local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'valkey.io/v1alpha1',
  kind: 'ValkeyCluster',
  metadata: {
    name: app.name + '-valkey',
    namespace: app.namespace,
    annotations: {
      'argocd.argoproj.io/sync-options': 'SkipDryRunOnMissingResource=true',
    },
    labels: labels(app.name + '-valkey'),
  },
  spec: {
    shards: 1,
    replicas: 3,
    persistence: {
      size: '1Gi',
    },
    resources: {
      requests: {
        cpu: '5m',
        memory: '5Mi',
      },
      limits: {
        cpu: '1',
        memory: '1Gi',
      },
    },
  },
}
