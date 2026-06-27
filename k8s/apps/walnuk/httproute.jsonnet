local gateway = import '../envoy-gateway-class/gateway.jsonnet';
local app = import 'app.json5';
local httpRouteFilter = import 'http-route-filter.jsonnet';
local serviceBackend = import 'service-backend.jsonnet';
local serviceFrontend = import 'service-frontend.jsonnet';
{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    annotations: {
      'external-dns-cloudflare.alpha.kubernetes.io/cloudflare-proxied': 'true',
    },
  },
  spec: {
    parentRefs: [
      {
        name: gateway.metadata.name,
        namespace: gateway.metadata.namespace,
      },
    ],
    hostnames: [
      'waln.uk',
    ],
    rules: [
      {
        backendRefs: [
          {
            kind: 'Service',
            name: serviceBackend.metadata.name,
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
              name: httpRouteFilter.metadata.name,
            },
          },
        ],
      },
      {
        backendRefs: [
          {
            kind: 'Service',
            name: serviceFrontend.metadata.name,
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
