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
      'waln.uk',
    ],
    rules: [
      {
        matches: [
          {
            path: {
              type: 'PathPrefix',
              value: '/pages/admin',
            },
          },
        ],
        filters: [
          {
            type: 'ExtensionRef',
            extensionRef: {
              group: 'gateway.envoyproxy.io',
              kind: 'HTTPRouteFilter',
              name: (import 'http-route-filter.jsonnet').metadata.name,
            },
          },
        ],
      },
      {
        backendRefs: [
          {
            kind: 'Service',
            name: (import 'service-backend.jsonnet').metadata.name,
            port: 8080,
            weight: 1,
          },
        ],
        matches: [
          {
            path: {
              type: 'RegularExpression',
              value: '/[A-Za-z0-9]+',
            },
          },
        ],
      },
      {
        backendRefs: [
          {
            kind: 'Service',
            name: (import 'service-frontend.jsonnet').metadata.name,
            port: 3000,
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
          {
            path: {
              type: 'PathPrefix',
              value: '/pages',
            },
          },
        ],
      },
    ],
  },
}
