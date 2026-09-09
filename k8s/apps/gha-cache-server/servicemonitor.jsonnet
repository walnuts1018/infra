local app = import 'app.json5';

{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (import '../../components/labels.libsonnet')(app.name),
  },
  spec: {
    endpoints: [
      {
        port: 'cache',
        path: '/metrics',
        interval: '15s',
      },
    ],
    selector: {
      matchLabels: {
        'app.kubernetes.io/instance': 'gha-cache-server',
        'app.kubernetes.io/name': 'github-actions-cache-server',
      },
    },
  },
}
