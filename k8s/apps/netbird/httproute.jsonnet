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
    parentRefs: [{
      name: gateway.metadata.name,
      namespace: gateway.metadata.namespace,
    }],
    hostnames: ['netbird.walnuts.dev'],
    rules: [
      {
        matches: [
          {
            path: {
              type: 'PathPrefix',
              value: '/signalexchange.SignalExchange/',
            },
          },
          {
            path: {
              type: 'PathPrefix',
              value: '/management.ManagementService/',
            },
          },
          {
            path: {
              type: 'PathPrefix',
              value: '/management.ProxyService/',
            },
          },
        ],
        backendRefs: [{
          name: (import 'server-service.jsonnet').metadata.name,
          port: 81,
        }],
      },
      {
        matches: [
          {
            path: {
              type: 'PathPrefix',
              value: '/api',
            },
          },
          {
            path: {
              type: 'PathPrefix',
              value: '/oauth2',
            },
          },
          {
            path: {
              type: 'PathPrefix',
              value: '/relay',
            },
          },
          {
            path: {
              type: 'PathPrefix',
              value: '/ws-proxy/',
            },
          },
        ],
        backendRefs: [{
          name: (import 'server-service.jsonnet').metadata.name,
          port: 80,
        }],
      },
      {
        backendRefs: [{
          name: (import 'dashboard-service.jsonnet').metadata.name,
          port: 80,
        }],
      },
    ],
  },
}
