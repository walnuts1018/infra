local networkPolicy = import '../../../components/network-policy.libsonnet';

local app = import '../app.json5';

{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: 'vyos-collector-ingress',
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: {
        'app.kubernetes.io/component': 'opentelemetry-collector',
        'app.kubernetes.io/instance': app.namespace + '.vyos',
      },
    },
    policyTypes: ['Ingress'],
    ingress: [{
      from: [networkPolicy.vyosRouter],
      ports: [{ protocol: 'UDP', port: 5514 }],
    }],
  },
}
