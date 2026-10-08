local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';

{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-frontend-ingress',
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: {
        app: 'picca-frontend',
        'app.kubernetes.io/name': 'picca-frontend',
      },
    },
    policyTypes: ['Ingress'],
    ingress: [{
      from: [networkPolicy.envoyGatewayProxy],
      ports: [{ protocol: 'TCP', port: 3000 }],
    }],
  },
}
