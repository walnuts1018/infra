local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: { name: app.name + '-encoder-egress', namespace: app.namespace },
  spec: {
    podSelector: { matchLabels: { 'app.kubernetes.io/name': 'encoder' } },
    policyTypes: ['Egress'],
    egress: [
      {
        to: [{ namespaceSelector: { matchLabels: { 'kubernetes.io/metadata.name': 'rabbitmq' } }, podSelector: { matchLabels: { 'app.kubernetes.io/name': 'default' } } }],
        ports: [{ protocol: 'TCP', port: 5672 }],
      },
      {
        to: [{ namespaceSelector: { matchLabels: { 'kubernetes.io/metadata.name': 'seaweedfs' } }, podSelector: { matchLabels: { 'app.kubernetes.io/component': 's3', 'app.kubernetes.io/instance': 'seaweedfs-default', 'app.kubernetes.io/name': 'seaweedfs' } } }],
        ports: [{ protocol: 'TCP', port: 8333 }],
      },
      { to: networkPolicy.publicInternet, ports: [{ protocol: 'TCP', port: 443 }] },
    ],
  },
}
