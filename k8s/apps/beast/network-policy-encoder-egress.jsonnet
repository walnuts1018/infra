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
        to: [
          { namespaceSelector: { matchLabels: { 'kubernetes.io/metadata.name': 'rabbitmq' } } },
          { namespaceSelector: { matchLabels: { 'kubernetes.io/metadata.name': 'seaweedfs' } } },
        ],
        ports: [
          { protocol: 'TCP', port: 5672 },
          { protocol: 'TCP', port: 8333 },
        ],
      },
      { to: [{ ipBlock: { cidr: '0.0.0.0/0' } }], ports: [{ protocol: 'TCP', port: 443 }] },
    ],
  },
}
