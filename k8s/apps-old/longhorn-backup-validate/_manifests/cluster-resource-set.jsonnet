{
  apiVersion: 'addons.cluster.x-k8s.io/v1beta2',
  kind: 'ClusterResourceSet',
  metadata: {
    name: (import '../app.json5').name + '-resourceset',
    namespace: (import '../app.json5').namespace,
  },
  spec: {
    strategy: 'Reconcile',
    clusterSelector: {
      matchLabels: (import 'cluster.jsonnet').metadata.labels,
    },
    resources: [
      {
        kind: 'Secret',
        name: (import 'external-secret.jsonnet').spec.target.name,
      },
    ],
  },
}
