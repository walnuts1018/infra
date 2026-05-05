{
  apiVersion: 'bootstrap.cluster.x-k8s.io/v1beta2',
  kind: 'KubeadmConfigTemplate',
  metadata: {
    name: (import 'cluster.json5').name,
    namespace: (import 'cluster.json5').namespace,
  },
}
