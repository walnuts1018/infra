{
  apiVersion: 'infrastructure.cluster.x-k8s.io/v1beta1',
  kind: 'TartCluster',
  metadata: {
    name: (import 'cluster.json5').name,
    namespace: (import 'cluster.json5').namespace,
    labels: {
      'cluster.x-k8s.io/cluster-name': (import 'cluster.json5').name,
    },
  },
  spec: {
    artifactPolicy: {
      allowedRegistries: ['ghcr.io'],
    },
  },
}
