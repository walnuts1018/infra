
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'kube-etcd-metrics-proxy',
    namespace: 'kube-system',
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').name) + {
      app: 'kube-etcd-metrics-proxy',
      jobLabel: 'kube-etcd',
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
        port: 12381,
        targetPort: 12381,
      },
    ],
  },
}
