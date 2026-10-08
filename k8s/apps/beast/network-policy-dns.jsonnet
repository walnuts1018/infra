local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: { name: app.name + '-dns-egress', namespace: app.namespace },
  spec: {
    podSelector: {},
    policyTypes: ['Egress'],
    egress: [{
      to: [networkPolicy.kubeDns],
      ports: [
        { protocol: 'UDP', port: 53 },
        { protocol: 'TCP', port: 53 },
      ],
    }],
  },
}
