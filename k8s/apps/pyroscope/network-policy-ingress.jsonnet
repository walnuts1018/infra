local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';
local pyroscopePods = {
  matchLabels: {
    'app.kubernetes.io/component': 'all',
    'app.kubernetes.io/instance': app.name,
    'app.kubernetes.io/name': app.name,
  },
};

{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-ingress',
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: pyroscopePods.matchLabels,
    },
    policyTypes: ['Ingress'],
    ingress: [
      {
        from: [networkPolicy.otelPrometheusCollector],
        ports: [{ protocol: 'TCP', port: 4040 }],
      },
      {
        from: [{ podSelector: pyroscopePods }],
        ports: [
          { protocol: 'TCP', port: 9095 },
          { protocol: 'TCP', port: 9099 },
          { protocol: 'TCP', port: 7946 },
        ],
      },
    ],
  },
}
