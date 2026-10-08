local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: (import '../../components/labels.libsonnet')(app.name),
    },
    policyTypes: [
      'Egress',
    ],
    egress: [
      {
        to: [networkPolicy.otelDefaultCollector],
        ports: [{ protocol: 'TCP', port: 4317 }],
      },
      {
        to: [{ namespaceSelector: { matchLabels: { 'kubernetes.io/metadata.name': 'databases' } }, podSelector: { matchLabels: { 'scylla/cluster': 'scylla-cluster' } } }],
        ports: [{ protocol: 'TCP', port: 9142 }],
      },
      { to: networkPolicy.publicInternet, ports: [{ protocol: 'TCP', port: 443 }] },
    ] + [
      {
        to: [networkPolicy.kubeDns],
        ports: [{ protocol: 'UDP', port: 53 }, { protocol: 'TCP', port: 53 }],
      },
    ],
  },
}
