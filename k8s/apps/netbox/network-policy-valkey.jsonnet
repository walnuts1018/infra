local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';

{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-valkey-access',
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: {
        'app.kubernetes.io/instance': app.name,
        'app.kubernetes.io/name': 'valkey',
      },
    },
    policyTypes: ['Ingress', 'Egress'],
    ingress: [{
      from: [
        { podSelector: { matchLabels: { 'netbox-valkey-client': 'true' } } },
        {
          namespaceSelector: {
            matchLabels: { 'kubernetes.io/metadata.name': app.namespace },
          },
          podSelector: {
            matchLabels: {
              'app.kubernetes.io/instance': app.name,
              'app.kubernetes.io/name': app.name,
            },
          },
        },
        {
          podSelector: {
            matchLabels: {
              'app.kubernetes.io/instance': app.name,
              'app.kubernetes.io/name': 'valkey',
            },
          },
        },
      ],
      ports: [{ protocol: 'TCP', port: 6379 }],
    }],
    egress: [
      {
        to: [networkPolicy.kubeDns],
        ports: [
          { protocol: 'UDP', port: 53 },
          { protocol: 'TCP', port: 53 },
        ],
      },
      {
        to: [{
          podSelector: {
            matchLabels: {
              'app.kubernetes.io/instance': app.name,
              'app.kubernetes.io/name': 'valkey',
            },
          },
        }],
        ports: [{ protocol: 'TCP', port: 6379 }],
      },
    ],
  },
}
