local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';
local grafanaSelector = {
  'app.kubernetes.io/instance': app.name,
  'app.kubernetes.io/name': app.name,
};

{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-ingress',
    namespace: app.namespace,
  },
  spec: {
    podSelector: { matchLabels: grafanaSelector },
    policyTypes: ['Ingress'],
    ingress: [
      {
        from: [networkPolicy.envoyGatewayProxy],
        ports: [{ protocol: 'TCP', port: 3000 }],
      },
      {
        from: [{ podSelector: { matchLabels: grafanaSelector } }],
        ports: [
          { protocol: 'TCP', port: 9094 },
          { protocol: 'UDP', port: 9094 },
        ],
      },
    ],
  },
}
