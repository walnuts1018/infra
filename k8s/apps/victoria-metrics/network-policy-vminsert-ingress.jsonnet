local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-vminsert-ingress',
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: {
        'app.kubernetes.io/component': 'vminsert',
        'app.kubernetes.io/instance': app.name,
        'app.kubernetes.io/name': 'victoria-metrics-cluster',
      },
    },
    policyTypes: ['Ingress'],
    ingress: [
      {
        from: [networkPolicy.otelCollectors],
        ports: [
          {
            protocol: 'TCP',
            port: 8480,
          },
        ],
      },
    ],
  },
}
