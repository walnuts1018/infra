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
      matchLabels: {
        'app.kubernetes.io/name': app.name,
        'app.kubernetes.io/instance': app.name,
      },
    },
    policyTypes: ['Ingress'],
    ingress: [
      {
        from: [
          networkPolicy.envoyGatewayProxy,
          networkPolicy.kedaHttpInterceptor,
        ],
        ports: [
          {
            port: 9280,
            protocol: 'TCP',
          },
        ],
      },
    ],
  },
}
