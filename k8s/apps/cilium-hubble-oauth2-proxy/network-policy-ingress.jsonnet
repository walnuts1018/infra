local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';

{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-ingress',
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: {
        'k8s-app': 'hubble-ui',
      },
    },
    policyTypes: ['Ingress'],
    ingress: [{
      from: [networkPolicy.envoyGatewayProxy],
      ports: [{ protocol: 'TCP', port: 8081 }],
    }],
  },
}
