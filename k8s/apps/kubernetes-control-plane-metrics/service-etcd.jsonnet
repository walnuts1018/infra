local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';

{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'kube-etcd',
    namespace: 'kube-system',
    labels: labels(app.name) + {
      app: 'kube-etcd',
      jobLabel: 'kube-etcd',
    },
  },
  spec: {
    clusterIP: 'None',
    selector: {
      component: 'etcd',
    },
    ports: [
      {
        name: 'http-metrics',
        port: 2381,
        targetPort: 2381,
      },
    ],
  },
}
