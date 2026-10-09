local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: 'samba-prober',
    namespace: app.namespace,
    labels: labels('samba-prober'),
  },
  spec: {
    namespaceSelector: {
      matchNames: [app.namespace],
    },
    selector: {
      matchLabels: labels('samba-prober'),
    },
    endpoints: [
      {
        port: 'metrics',
        path: '/metrics',
        interval: '30s',
      },
    ],
  },
}
