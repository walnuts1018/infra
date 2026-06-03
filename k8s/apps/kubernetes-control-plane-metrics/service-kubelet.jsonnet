local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';

{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'kubelet',
    namespace: 'kube-system',
    labels: labels(app.name) + {
      'app.kubernetes.io/name': 'kubelet',
      'k8s-app': 'kubelet',
    },
  },
  spec: {
    clusterIP: 'None',
    selector: {
      app: 'kubelet-metrics-proxy',
    },
    ports: [
      {
        name: 'https-metrics',
        port: 11050,
        targetPort: 11050,
      },
    ],
  },
}
