{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'kube-controller-manager-metrics-proxy',
    namespace: 'kube-system',
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').name) + {
      app: 'kube-controller-manager-metrics-proxy',
      jobLabel: 'kube-controller-manager',
    },
  },
  spec: {
    clusterIP: 'None',
    selector: {
      app: 'kubernetes-control-plane-metrics-proxy',
    },
    ports: [
      {
        name: 'http-metrics',
        port: 11057,
        targetPort: 11057,
      },
    ],
  },
}
