local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-gateway-ingress',
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: {
        'app.kubernetes.io/component': 'gateway',
        'app.kubernetes.io/instance': app.name,
        'app.kubernetes.io/name': app.name,
      },
    },
    policyTypes: ['Ingress'],
    ingress: [
      {
        from: [networkPolicy.grafana],
        ports: [{ protocol: 'TCP', port: 8080 }],
      },
      {
        from: [networkPolicy.otelDefaultCollector],
        ports: [{ protocol: 'TCP', port: 4317 }],
      },
    ],
  },
}
