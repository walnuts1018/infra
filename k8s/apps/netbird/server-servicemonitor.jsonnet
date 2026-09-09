local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: app.name + '-server',
    namespace: app.namespace,
    labels: labels(app.name + '-server'),
  },
  spec: {
    namespaceSelector: {
      matchNames: [app.namespace],
    },
    selector: {
      matchLabels: labels(app.name + '-server'),
    },
    endpoints: [
      {
        port: 'metrics',
        path: '/metrics',
      },
    ],
  },
}
