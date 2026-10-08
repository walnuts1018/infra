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
        to: [
          networkPolicy.kubeDns,
        ],
        ports: [{ protocol: 'UDP', port: 53 }, { protocol: 'TCP', port: 53 }],
      },
      {
        to: networkPolicy.publicInternet,
        ports: [{ protocol: 'TCP', port: 80 }, { protocol: 'TCP', port: 443 }],
      },
    ],
  },
}
