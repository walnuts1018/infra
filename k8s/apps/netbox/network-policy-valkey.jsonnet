local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';
local netboxPods = {
  'app.kubernetes.io/instance': app.name,
  'app.kubernetes.io/name': app.name,
};
local valkeyPods = {
  'app.kubernetes.io/instance': app.name,
  'app.kubernetes.io/name': 'valkey',
};

{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-valkey-network-policy',
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: valkeyPods,
    },
    policyTypes: ['Ingress', 'Egress'],
    ingress: [{
      from: [
        {
          namespaceSelector: {
            matchLabels: {
              'kubernetes.io/metadata.name': app.namespace,
            },
          },
          podSelector: {
            matchLabels: netboxPods,
          },
        },
        {
          podSelector: {
            matchLabels: valkeyPods,
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
        to: [{ podSelector: { matchLabels: valkeyPods } }],
        ports: [{ protocol: 'TCP', port: 6379 }],
      },
    ],
  },
}
