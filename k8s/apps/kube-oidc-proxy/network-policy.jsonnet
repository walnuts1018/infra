local app = import 'app.json5';

{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: {
        'app.kubernetes.io/name': app.name,
      },
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
                'app.kubernetes.io/managed-by': 'envoy-gateway',
                'app.kubernetes.io/name': 'envoy',
              },
            },
          },
        ],
        ports: [
          {
            port: 8443,
            protocol: 'TCP',
          },
        ],
      },
    ],
  },
}
