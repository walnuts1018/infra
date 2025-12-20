{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: (import 'app.json5').name + '-www',
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
      'www.walnuts.dev',
    ],
    rules: [
      {
        filters: [
          {
            type: 'RequestRedirect',
            requestRedirect: {
              scheme: 'https',
              hostname: 'walnuts.dev',
              statusCode: 308,
            },
          },
        ],
      },
    ],
  },
}
