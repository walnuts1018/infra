local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';

{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'kube-scheduler',
    namespace: 'kube-system',
    labels: labels(app.name) + {
      app: 'kube-scheduler',
      jobLabel: 'kube-scheduler',
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
        port: 11059,
        targetPort: 11059,
      },
    ],
  },
}
