local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: app.name + '-backend',
    namespace: app.namespace,
    labels: labels(app.name + '-backend'),
  },
  spec: {
    namespaceSelector: {
      matchNames: [app.namespace],
    },
    selector: {
      matchLabels: {
        'app.kubernetes.io/name': app.name,
        'app.kubernetes.io/instance': app.name,
      },
    },
    endpoints: [
      {
        port: 'http',
        path: '/metrics',
        relabelings: [
          {
            sourceLabels: ['__meta_kubernetes_service_name'],
            regex: app.name + '-backend',
            action: 'keep',
          },
        ],
      },
    ],
  },
}
