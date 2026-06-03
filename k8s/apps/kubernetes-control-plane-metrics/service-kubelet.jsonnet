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
    ports: [
      {
        name: 'https-metrics',
        port: 10250,
        targetPort: 10250,
      },
      {
        name: 'cadvisor',
        port: 4194,
        targetPort: 4194,
      },
      {
        name: 'http-metrics',
        port: 10255,
        targetPort: 10255,
      },
    ],
  },
}
