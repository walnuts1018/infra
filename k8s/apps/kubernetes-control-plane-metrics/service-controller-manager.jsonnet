local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';

{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'kube-controller-manager',
    namespace: 'kube-system',
    labels: labels(app.name) + {
      app: 'kube-controller-manager',
      jobLabel: 'kube-controller-manager',
    },
  },
  spec: {
    clusterIP: 'None',
    selector: {
      component: 'kube-controller-manager',
    },
    ports: [
      {
        name: 'http-metrics',
        port: 10257,
        targetPort: 10257,
      },
    ],
  },
}
