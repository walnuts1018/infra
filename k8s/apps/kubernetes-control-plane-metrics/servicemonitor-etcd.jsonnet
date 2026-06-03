local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';

{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: 'kube-etcd',
    namespace: app.namespace,
    labels: labels(app.name),
  },
  spec: {
    jobLabel: 'jobLabel',
    namespaceSelector: {
      matchNames: ['kube-system'],
    },
    selector: {
      matchLabels: {
        app: 'kube-etcd',
      },
    },
    endpoints: [
      {
        bearerTokenFile: '/var/run/secrets/kubernetes.io/serviceaccount/token',
        port: 'http-metrics',
      },
    ],
  },
}
