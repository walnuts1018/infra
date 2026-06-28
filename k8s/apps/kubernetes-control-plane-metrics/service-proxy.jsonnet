local app = import 'app.json5';

{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'kube-proxy-metrics',
    namespace: 'kube-system',
    labels: (import '../../components/labels.libsonnet')(app.name) + {
      app: 'kube-proxy-metrics',
      jobLabel: 'kube-proxy',
    },
  },
  spec: {
    clusterIP: 'None',
    selector: {
      'k8s-app': 'kube-proxy',
    },
    ports: [
      {
        name: 'http-metrics',
        port: 10249,
        targetPort: 10249,
      },
    ],
  },
}
