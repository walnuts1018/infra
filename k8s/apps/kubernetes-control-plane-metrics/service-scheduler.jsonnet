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
      component: 'kube-scheduler',
    },
    ports: [
      {
        name: 'http-metrics',
        port: 10259,
        targetPort: 10259,
      },
    ],
  },
}
