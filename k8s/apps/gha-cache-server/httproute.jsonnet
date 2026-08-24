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
      'gha-cache-server.local.walnuts.dev',
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
            name: 'gha-cache-server-github-actions-cache-server',
            port: 3000,
          },
        ],
      },
    ],
  },
}
