{
  apiVersion: 'cluster.x-k8s.io/v1beta1',
  kind: 'MachineHealthCheck',
  metadata: {
    name: (import 'app.json5').name + '-worker',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    clusterName: (import 'app.json5').name,
    maxUnhealthy: '100%',
    nodeStartupTimeout: '10m',
    selector: {
      matchLabels: {
        'cluster.x-k8s.io/deployment-name': (import 'app.json5').name + '-worker',
      },
    },
    unhealthyConditions: [
      {
        type: 'Ready',
        status: 'Unknown',
        timeout: '300s',
      },
      {
        type: 'Ready',
        status: 'False',
        timeout: '300s',
      },
    ],
  },
}
