local app = import 'app.json5';

{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'PodMonitor',
  metadata: {
    name: 'arc-runner-set-listener',
    namespace: app.namespace,
    labels: (import '../../components/labels.libsonnet')(app.name),
  },
  spec: {
    namespaceSelector: {
      matchNames: [
        'arc-systems',
      ],
    },
    podMetricsEndpoints: [
      {
        port: 'metrics',
        path: '/metrics',
        interval: '15s',
      },
    ],
    selector: {
      matchLabels: {
        'app.kubernetes.io/component': 'runner-scale-set-listener',
      },
    },
  },
}
