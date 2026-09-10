function(cluster) {
  apiVersion: 'addons.cluster.x-k8s.io/v1beta2',
  kind: 'ClusterResourceSet',
  metadata: {
    name: 'argocd-agent',
    namespace: cluster.namespace,
    annotations: {
      'argocd.argoproj.io/sync-wave': '22',
    },
  },
  spec: {
    // cluster-nameも含めて絞り込む: 'argocd-agent.walnuts.dev/enabled'だけだと他clusterの
    // 同名ClusterResourceSetともお互いのClusterへ二重適用されてしまう。
    clusterSelector: {
      matchLabels: {
        'argocd-agent.walnuts.dev/enabled': 'true',
        'cluster.x-k8s.io/cluster-name': cluster.name,
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
