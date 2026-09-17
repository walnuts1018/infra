local app = import 'app.json5';
local collectorLabels = {
  'app.kubernetes.io/component': 'opentelemetry-collector',
  'app.kubernetes.io/instance': 'synthetic-monitoring.synthetic-otel-collector',
};
local prometheusCollectorLabels = {
  'app.kubernetes.io/component': 'opentelemetry-collector',
  'app.kubernetes.io/instance': 'opentelemetry-collector.prometheus',
};
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: { name: app.name + '-ingress', namespace: app.namespace },
  spec: {
    podSelector: { matchLabels: { 'app.kubernetes.io/name': app.name } },
    policyTypes: ['Ingress'],
    ingress: [{
      from: [
        {
          namespaceSelector: { matchLabels: { 'kubernetes.io/metadata.name': 'synthetic-monitoring' } },
          podSelector: { matchLabels: collectorLabels },
        },
        {
          namespaceSelector: { matchLabels: { 'kubernetes.io/metadata.name': 'envoy-gateway-system' } },
          podSelector: { matchLabels: { 'app.kubernetes.io/component': 'proxy', 'app.kubernetes.io/name': 'envoy' } },
        },
        {
          namespaceSelector: { matchLabels: { 'kubernetes.io/metadata.name': 'opentelemetry-collector' } },
          podSelector: { matchLabels: prometheusCollectorLabels },
        },
      ],
      ports: [{ protocol: 'TCP', port: 8080 }],
    }],
  },
}
