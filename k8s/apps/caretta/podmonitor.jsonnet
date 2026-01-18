{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'PodMonitor',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
  },
  spec: {
    podMetricsEndpoints: [
      {
        port: 'prom-metrics',
      },
    ],
    selector: {
      matchLabels: {
        app: (import 'app.json5').name,
        'app.kubernetes.io/name': (import 'app.json5').name,
        'app.kubernetes.io/instance': (import 'app.json5').name,
      },
    },
  },
}
