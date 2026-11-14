local labels = import '../../components/labels.libsonnet';
local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-web',
    namespace: app.namespace,
  },
  spec: {
    podSelector: { matchLabels: labels(app.name + '-web') },
    policyTypes: ['Ingress', 'Egress'],
    ingress: [{
      from: [networkPolicy.envoyGatewayProxy],
      ports: [{ protocol: 'TCP', port: 3000 }],
    }],
    egress: [
      {
        to: [networkPolicy.kubeDns],
        ports: [{ protocol: 'UDP', port: 53 }, { protocol: 'TCP', port: 53 }],
      },
      {
        to: [{ podSelector: { matchLabels: labels(app.name + '-server') } }],
        ports: [{ protocol: 'TCP', port: 8080 }],
      },
    ],
  },
}
