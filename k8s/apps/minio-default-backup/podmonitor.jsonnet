local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'PodMonitor',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (labels)(app.name),
  },
  spec: {
    podMetricsEndpoints: [
      {
        port: 'metrics',
      },
    ],
    selector: {
      matchLabels: (labels)(app.name),
    },
  },
}
