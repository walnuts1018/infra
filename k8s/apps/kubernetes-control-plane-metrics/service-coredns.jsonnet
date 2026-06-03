local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';

{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'kubernetes-coredns',
    namespace: 'kube-system',
    labels: labels(app.name) + {
      app: 'kubernetes-coredns',
      jobLabel: 'kubernetes-coredns',
    },
  },
  spec: {
    clusterIP: 'None',
    selector: {
      'k8s-app': 'kube-dns',
    },
    ports: [
      {
        name: 'http-metrics',
        port: 9153,
        targetPort: 9153,
      },
    ],
  },
}
