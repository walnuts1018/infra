local cluster = import 'cluster.json5';
{
  apiVersion: 'addons.cluster.x-k8s.io/v1beta2',
  kind: 'ClusterResourceSet',
  metadata: {
    name: 'argocd-agent',
    namespace: cluster.namespace,
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
        name: 'argocd-agent-resources',
      },
    ],
    strategy: 'Reconcile',
  },
}
