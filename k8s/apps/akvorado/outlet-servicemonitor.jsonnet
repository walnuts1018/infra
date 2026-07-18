local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: 'akvorado-outlet',
    namespace: app.namespace,
    labels: labels('akvorado') + {
      'app.kubernetes.io/component': 'outlet',
    },
  },
  spec: {
    namespaceSelector: {
      matchNames: [app.namespace],
    },
    selector: {
      matchLabels: {
        'app.kubernetes.io/name': 'akvorado',
        'app.kubernetes.io/component': 'outlet',
      },
    },
    endpoints: [
      {
        port: 'http',
        path: '/api/v0/metrics',
      },
    ],
  },
}
