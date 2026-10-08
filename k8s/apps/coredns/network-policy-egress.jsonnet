local labels = import '../../components/labels.libsonnet';
local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-egress',
    namespace: app.namespace,
  },
  spec: {
    podSelector: { matchLabels: labels(app.name) },
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
              'kubernetes.io/metadata.name': app.namespace,
            },
          },
          podSelector: { matchLabels: labels('coredns-etcd') },
        }],
        ports: [{ protocol: 'TCP', port: 2379 }],
      },
      {
        to: [
          { ipBlock: { cidr: '1.1.1.1/32' } },
          { ipBlock: { cidr: '1.0.0.1/32' } },
        ],
        ports: [{ protocol: 'TCP', port: 53 }],
      },
    ],
  },
}
