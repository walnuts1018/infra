local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';

{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-pd-leader-prober',
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: {
        'app.kubernetes.io/name': 'pd-leader-prober',
        'app.kubernetes.io/instance': app.name,
      },
    },
    policyTypes: ['Ingress', 'Egress'],
    ingress: [
      {
        from: [networkPolicy.otelPrometheusCollector],
        ports: [{ protocol: 'TCP', port: 9115 }],
      },
    ],
    egress: [
      {
        to: [
          {
            podSelector: {
              matchLabels: {
                'app.kubernetes.io/component': 'pd',
                'app.kubernetes.io/instance': app.name,
              },
            },
          },
        ],
        ports: [{ protocol: 'TCP', port: 2379 }],
      },
      {
        to: [networkPolicy.kubeDns],
        ports: [
          { protocol: 'UDP', port: 53 },
          { protocol: 'TCP', port: 53 },
        ],
      },
    ],
  },
}
