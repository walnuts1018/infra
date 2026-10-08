local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';
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
        'app.kubernetes.io/name': 'influxdb2',
      },
    },
    policyTypes: ['Ingress'],
    ingress: [{
      from: [
        networkPolicy.envoyGatewayProxy,
        {
          namespaceSelector: {
            matchLabels: {
              'kubernetes.io/metadata.name': 'fitbit-manager',
            },
          },
          podSelector: {
            matchLabels: {
              'app.kubernetes.io/name': 'fitbit-manager',
            },
          },
        },
      ],
      ports: [{ protocol: 'TCP', port: 8086 }],
    }],
  },
}
