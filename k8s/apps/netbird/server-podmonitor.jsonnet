local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'PodMonitor',
  metadata: {
    name: app.name + '-server-metrics',
    namespace: app.namespace,
    labels: labels(app.name + '-server'),
  },
  spec: {
    namespaceSelector: {
      matchNames: [app.namespace],
    },
    podMetricsEndpoints: [
      {
        port: 'metrics',
        path: '/metrics',
        interval: '30s',
      },
    ],
    selector: {
      matchLabels: labels(app.name + '-server'),
    },
  },
}
