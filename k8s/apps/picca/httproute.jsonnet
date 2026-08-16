local gateway = import '../envoy-gateway-class/gateway.jsonnet';
local app = import 'app.json5';
[
  {
    apiVersion: 'gateway.networking.k8s.io/v1',
    kind: 'HTTPRoute',
    metadata: {
      name: app.name,
      namespace: app.namespace,
    },
    spec: {
      parentRefs: [
        { name: gateway.metadata.name, namespace: gateway.metadata.namespace },
      ],
      hostnames: [
        'picca.walnuts.dev',
      ],
      rules: [
        {
          matches: [
            { path: { type: 'PathPrefix', value: '/auth' } },
            { path: { type: 'PathPrefix', value: '/query' } },
            { path: { type: 'PathPrefix', value: '/api/media' } },
          ],
          timeouts: {
            request: '0s',
            backendRequest: '0s',
          },
          backendRefs: [
            { kind: 'Service', name: (import 'apiserver/service.jsonnet').metadata.name, port: 8080, weight: 1 },
          ],
        },
        {
          backendRefs: [
            { kind: 'Service', name: (import 'frontend/service.jsonnet').metadata.name, port: 3000, weight: 1 },
          ],
        },
      ],
    },
  },
  {
    apiVersion: 'gateway.networking.k8s.io/v1',
    kind: 'HTTPRoute',
    metadata: {
      name: app.name + '-imgproxy',
      namespace: app.namespace,
    },
    spec: {
      parentRefs: [
        { name: gateway.metadata.name, namespace: gateway.metadata.namespace },
      ],
      hostnames: [
        'imgproxy-picca.walnuts.dev',
      ],
      rules: [
        {
          backendRefs: [
            { kind: 'Service', name: (import 'imgproxy/service.jsonnet').metadata.name, port: 80, weight: 1 },
          ],
        },
      ],
    },
  },
]
