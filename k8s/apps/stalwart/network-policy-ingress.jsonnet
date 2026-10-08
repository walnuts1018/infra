local labels = import '../../components/labels.libsonnet';
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
    podSelector: { matchLabels: labels(app.name) },
    policyTypes: ['Ingress'],
    ingress: [{
      from: [networkPolicy.envoyGatewayProxy],
      ports: [
        { protocol: 'TCP', port: 8080 },
        { protocol: 'TCP', port: 443 },
        { protocol: 'TCP', port: 25 },
        { protocol: 'TCP', port: 465 },
        { protocol: 'TCP', port: 587 },
        { protocol: 'TCP', port: 993 },
      ],
    }],
  },
}
