local app = import 'app.json5';
local networkPolicy = import '../../components/network-policy.libsonnet';

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
        'app.kubernetes.io/instance': app.name,
      },
    },
    policyTypes: ['Ingress'],
    ingress: [
      {
        from: [networkPolicy.envoyGatewayProxy],
        ports: [{ protocol: 'TCP', port: 8080 }],
      },
      {
        from: [networkPolicy.otelPrometheusCollector],
        ports: [{ protocol: 'TCP', port: 9000 }],
      },
    ],
  },
}
