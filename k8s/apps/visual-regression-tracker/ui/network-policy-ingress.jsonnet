local labels = import '../../../components/labels.libsonnet';
local networkPolicy = import '../../../components/network-policy.libsonnet';
local app = import '../app.json5';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-ui-ingress',
    namespace: app.namespace,
  },
  spec: {
    podSelector: { matchLabels: labels(app.name + '-ui') },
    policyTypes: ['Ingress'],
    ingress: [{
      from: [networkPolicy.envoyGatewayProxy],
      ports: [{ protocol: 'TCP', port: 8080 }],
    }],
  },
}
