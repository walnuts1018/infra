local app = import 'app.json5';
local collectorLabels = {
  'app.kubernetes.io/component': 'opentelemetry-collector',
  'app.kubernetes.io/instance': app.namespace + '.iwashi-collector',
};
local prometheusCollectorLabels = {
  'app.kubernetes.io/component': 'opentelemetry-collector',
  'app.kubernetes.io/instance': 'opentelemetry-collector.prometheus',
};
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: { name: app.name, namespace: app.namespace },
  spec: {
    podSelector: { matchLabels: collectorLabels },
    policyTypes: ['Ingress', 'Egress'],
    ingress: [{
      from: [{
        namespaceSelector: {
          matchLabels: { 'kubernetes.io/metadata.name': 'opentelemetry-collector' },
        },
        podSelector: { matchLabels: prometheusCollectorLabels },
      }],
      ports: [{ protocol: 'TCP', port: 8888 }],
    }],
    egress: [
      { to: [{ namespaceSelector: { matchLabels: { 'kubernetes.io/metadata.name': 'kube-system' } }, podSelector: { matchLabels: { 'k8s-app': 'kube-dns' } } }], ports: [{ protocol: 'UDP', port: 53 }, { protocol: 'TCP', port: 53 }] },
      { to: [{ podSelector: { matchLabels: { 'app.kubernetes.io/name': 'iwashi' } } }], ports: [{ protocol: 'TCP', port: 8080 }] },
      { to: [{ namespaceSelector: { matchLabels: { 'kubernetes.io/metadata.name': 'iwashi-blackbox' } }, podSelector: { matchLabels: { 'app.kubernetes.io/name': 'prometheus-blackbox-exporter', 'app.kubernetes.io/instance': 'iwashi-blackbox' } } }], ports: [{ protocol: 'TCP', port: 9115 }] },
    ],
  },
}
