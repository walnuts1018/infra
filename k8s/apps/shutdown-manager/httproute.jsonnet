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
      },
    ],
    hostnames: [
      'shutdown-manager.local.walnuts.dev',
    ],
    rules: [
      {
        backendRefs: [
          {
            kind: 'Service',
            name: (import 'app.json5').name,
            port: 8000,
            weight: 1,
          },
        ],
        matches: [
          {
            path: {
              type: 'PathPrefix',
              value: '/',
            },
          },
        ],
      },
    ],
  },
}
