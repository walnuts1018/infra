{
  apiVersion: 'infrastructure.cluster.x-k8s.io/v1alpha1',
  kind: 'KubevirtCluster',
  metadata: {
    name: (import '../app.json5').name,
    namespace: (import '../app.json5').namespace,
  },
  spec: {
    controlPlaneServiceTemplate: {
      spec: {
        type: 'LoadBalancer',
      },
    },
  },
}
