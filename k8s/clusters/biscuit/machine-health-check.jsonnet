{
  apiVersion: 'cluster.x-k8s.io/v1beta2',
  kind: 'MachineHealthCheck',
  metadata: {
    name: (import 'cluster.json5').name,
    namespace: (import 'cluster.json5').namespace,
  },
  spec: {
    clusterName: (import 'cluster.jsonnet').metadata.name,
    selector: {
      matchLabels: {
        'cluster.x-k8s.io/cluster-name': (import 'cluster.json5').name,
      },
    },
  },
}
