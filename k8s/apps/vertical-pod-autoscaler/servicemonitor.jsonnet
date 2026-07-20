local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: labels(app.name) + {
      'app.kubernetes.io/component': 'recommender',
    },
  },
  spec: {
    namespaceSelector: {
      matchNames: [app.namespace],
    },
    selector: {
      matchLabels: {
        'app.kubernetes.io/name': 'vertical-pod-autoscaler',
        'app.kubernetes.io/component': 'recommender',
      },
    },
    endpoints: [
      {
        port: 'prometheus',
        path: '/metrics',
      },
    ],
  },
}
