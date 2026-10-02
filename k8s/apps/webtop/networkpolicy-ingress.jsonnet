local labels = import '../../components/labels.libsonnet';
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
      matchLabels: labels(app.name),
    },
    policyTypes: ['Ingress'],
    ingress: [
      {
        from: [
          {
            namespaceSelector: {
              matchLabels: {
                'kubernetes.io/metadata.name': 'envoy-gateway-system',
              },
            },
            podSelector: {
              matchLabels: {
                'app.kubernetes.io/component': 'proxy',
                'app.kubernetes.io/name': 'envoy',
              },
            },
          },
        ],
        ports: [
          {
            protocol: 'TCP',
            port: 3000,
          },
        ],
      },
    ],
  },
}
