local labels = import '../../components/labels.libsonnet';
local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';

{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-inlet-ingress',
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: labels(app.name) + {
        'app.kubernetes.io/component': 'inlet',
      },
    },
    policyTypes: ['Ingress'],
    ingress: [
      {
        from: [{ ipBlock: { cidr: '192.168.0.1/32' } }],
        ports: [
          { protocol: 'UDP', port: 2055 },
          { protocol: 'UDP', port: 6343 },
        ],
      },
      {
        from: [networkPolicy.otelPrometheusCollector],
        ports: [{ protocol: 'TCP', port: 8080 }],
      },
    ],
  },
}
