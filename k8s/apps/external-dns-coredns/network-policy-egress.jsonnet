local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';

local externalDns = {
  'app.kubernetes.io/instance': app.name,
  'app.kubernetes.io/name': 'external-dns',
};

{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-egress',
    namespace: app.namespace,
  },
  spec: {
    podSelector: { matchLabels: externalDns },
    policyTypes: ['Egress'],
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
          namespaceSelector: {
            matchLabels: {
              'kubernetes.io/metadata.name': 'coredns',
            },
          },
          podSelector: {
            matchLabels: {
              'app.kubernetes.io/name': 'coredns-etcd',
            },
          },
        }],
        ports: [{ protocol: 'TCP', port: 2379 }],
      },
    ],
  },
}
