local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';

{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'kubelet-metrics-proxy',
    namespace: 'kube-system',
    labels: labels(app.name) + {
      'app.kubernetes.io/name': 'kubelet-metrics-proxy',
      'k8s-app': 'kubelet',
    },
  },
  spec: {
    clusterIP: 'None',
    ipFamilies: ['IPv4'],
    ipFamilyPolicy: 'SingleStack',
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
