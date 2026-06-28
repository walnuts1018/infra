local gateway = import '../envoy-gateway-class/gateway.jsonnet';
local app = import 'app.json5';
{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    parentRefs: [
      {
        name: gateway.metadata.name,
        namespace: gateway.metadata.namespace,
      },
    ],
    hostnames: [
      'mucaron.walnuts.dev',
    ],
    rules: [
      {
        matches: [
          {
            path: {
              type: 'PathPrefix',
              value: '/api',
            },
          },
        ],
        backendRefs: [
          {
            kind: 'Service',
            name: (import './back/service.jsonnet').metadata.name,
            port: 8080,
            weight: 1,
          },
        ],
      },
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
            name: (import './front/service.jsonnet').metadata.name,
            port: 3000,
            weight: 1,
          },
        ],
      },
    ],
  },
}
