{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    parentRefs: [
      {
        name: (import '../envoy-gateway-class/gateway.jsonnet').metadata.name,
        namespace: (import '../envoy-gateway-class/gateway.jsonnet').metadata.namespace,
      },
    ],
    hostnames: [
      'misskey.walnuts.dev',
    ],
    rules: [
      {
        matches: [
          {
            path: {
              type: 'PathPrefix',
              value: '/',
            },
          },
        ],
        backendRefs: [
          {
            kind: 'Service',
            name: (import 'service.jsonnet').metadata.name,
            port: 8080,
            weight: 1,
          },
        ],
      },
    ],
  },
}
