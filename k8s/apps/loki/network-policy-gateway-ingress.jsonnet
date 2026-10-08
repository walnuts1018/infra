local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';
local lokiCanary = {
  podSelector: {
    matchLabels: {
      'app.kubernetes.io/component': 'canary',
      'app.kubernetes.io/instance': app.name,
      'app.kubernetes.io/name': app.name,
    },
  },
};

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
        from: [
          networkPolicy.otelDefaultCollector,
          networkPolicy.otelCollector('atomic'),
          networkPolicy.otelCollector('daemonset'),
          networkPolicy.otelCollector('vyos'),
          networkPolicy.grafana,
          lokiCanary,
        ],
        ports: [{ protocol: 'TCP', port: 8080 }],
      },
      {
        from: [networkPolicy.otelPrometheusCollector],
        ports: [{ protocol: 'TCP', port: 4040 }],
      },
    ],
  },
}
