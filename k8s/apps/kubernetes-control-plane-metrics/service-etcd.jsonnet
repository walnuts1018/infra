local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';

{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'kube-etcd-metrics-proxy',
    namespace: 'kube-system',
    labels: labels(app.name) + {
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
