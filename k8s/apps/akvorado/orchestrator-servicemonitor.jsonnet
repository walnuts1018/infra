local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: 'akvorado-orchestrator',
    namespace: app.namespace,
    labels: labels('akvorado') + {
      'app.kubernetes.io/component': 'orchestrator',
    },
  },
  spec: {
    namespaceSelector: {
      matchNames: [app.namespace],
    },
    selector: {
      matchLabels: {
        'app.kubernetes.io/name': 'akvorado',
        'app.kubernetes.io/component': 'orchestrator',
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
