local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';

{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'PodMonitor',
  metadata: {
    name: 'cnpg-cluster-instances',
    namespace: app.namespace,
    labels: labels(app.name),
  },
  spec: {
    selector: {
      matchLabels: {
        'cnpg.io/cluster': app.name,
        'cnpg.io/podRole': 'instance',
      },
    },
    podMetricsEndpoints: [
      {
        port: 'metrics',
        path: '/metrics',
        interval: '30s',
      },
    ],
  },
}
