local cluster = import 'cluster.json5';
{
  apiVersion: 'addons.cluster.x-k8s.io/v1beta2',
  kind: 'ClusterResourceSet',
  metadata: {
    name: 'gateway-api-crds',
    namespace: cluster.namespace,
    annotations: {
      'argocd.argoproj.io/sync-wave': '19',
    },
  },
  spec: {
    clusterSelector: {
      matchLabels: {
        'argocd-agent.walnuts.dev/enabled': 'true',
      },
    },
    resources: [
      {
        kind: 'Secret',
        name: 'gateway-api-crds-resources',
      },
    ],
    strategy: 'Reconcile',
  },
}
