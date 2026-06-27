local app = import 'app.json5';
{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'PodMonitor',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (import '../../components/labels.libsonnet')(app.name),
  },
  spec: {
    podMetricsEndpoints: [
      {
        port: 'prom-metrics',
      },
    ],
    selector: {
      matchLabels: {
        app: app.name,
        'app.kubernetes.io/name': app.name,
        'app.kubernetes.io/instance': app.name,
      },
    },
  },
}
