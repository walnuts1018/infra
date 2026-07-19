local app = import 'app.json5';
{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'PodMonitor',
  metadata: {
    name: 'envoy-gateway-proxy',
    namespace: app.namespace,
    labels: (import '../../components/labels.libsonnet')('envoy-gateway-proxy'),
  },
  spec: {
    podMetricsEndpoints: [
      {
        path: '/stats/prometheus',
        port: 'metrics',
      },
    ],
    namespaceSelector: {
      matchNames: [
        app.namespace,
      ],
    },
    selector: {
      matchLabels: {
        'app.kubernetes.io/name': 'envoy',
        'app.kubernetes.io/component': 'proxy',
      },
    },
  },
}
