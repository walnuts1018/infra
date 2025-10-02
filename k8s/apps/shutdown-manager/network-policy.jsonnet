{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    podSelector: {
      matchLabels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
    },
    policyTypes: [
      'Ingress',
    ],
    ingress: [
      {
        from: [
          {
            namespaceSelector: {
              matchLabels: {
                'kubernetes.io/metadata.name': (import '../envoy-gateway-class/gateway.jsonnet').metadata.namespace,
              },
            },
            podSelector: {
              matchLabels: {
                'gateway.envoyproxy.io/owning-gateway-name': (import '../envoy-gateway-class/gateway.jsonnet').metadata.name,
                'gateway.envoyproxy.io/owning-gateway-namespace': (import '../envoy-gateway-class/gateway.jsonnet').metadata.namespace,
              },
            },
          },
        ],
      },
    ],
  },
}
