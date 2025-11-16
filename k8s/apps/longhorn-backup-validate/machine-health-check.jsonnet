{
  apiVersion: 'cluster.x-k8s.io/v1beta2',
  kind: 'MachineHealthCheck',
  metadata: {
    name: (import 'app.json5').name + '-worker',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    clusterName: (import 'app.json5').name,
    selector: {
      matchLabels: {
        'cluster.x-k8s.io/cluster-name': (import 'app.json5').name,
      },
    },
  },
}
