local labels = import '../../components/labels.libsonnet';
local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.appname.backend + '-ingress',
    namespace: app.namespace,
  },
  spec: {
    podSelector: { matchLabels: labels(app.appname.backend) },
    policyTypes: ['Ingress'],
    ingress: [{
      from: [
        networkPolicy.envoyGatewayProxy,
        { podSelector: { matchLabels: labels(app.appname.frontend) } },
      ],
      ports: [{ protocol: 'TCP', port: 8080 }],
    }],
  },
}
