local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';

{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: labels(app.name),
  },
  spec: {
    namespaceSelector: {
      matchNames: [app.namespace],
    },
    selector: {
      matchLabels: {
        'app.kubernetes.io/name': 'default',
        'app.kubernetes.io/component': 'rabbitmq',
      },
    },
    endpoints: [
      {
        port: 'prometheus',
        scheme: 'http',
        path: '/metrics',
        interval: '15s',
        scrapeTimeout: '14s',
      },
      {
        port: 'prometheus',
        scheme: 'http',
        path: '/metrics/detailed',
        params: {
          family: [
            'queue_coarse_metrics',
            'queue_metrics',
          ],
        },
        interval: '15s',
        scrapeTimeout: '14s',
      },
    ],
  },
}
