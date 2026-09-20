function(cluster) {
  apiVersion: 'infrastructure.cluster.x-k8s.io/v1alpha1',
  kind: 'TartCluster',
  metadata: {
    name: cluster.name,
    namespace: cluster.namespace,
    labels: {
      'cluster.x-k8s.io/cluster-name': cluster.name,
    },
  },
  spec: {},
}
