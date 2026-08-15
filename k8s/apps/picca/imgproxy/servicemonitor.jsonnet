local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: app.name + '-imgproxy',
    namespace: app.namespace,
    labels: (labels)(app.name + '-imgproxy'),
  },
  spec: {
    namespaceSelector: {
      matchNames: [app.namespace],
    },
    selector: {
      matchLabels: (labels)(app.name + '-imgproxy'),
    },
    endpoints: [
      {
        port: 'metrics',
        path: '/metrics',
      },
    ],
  },
}
