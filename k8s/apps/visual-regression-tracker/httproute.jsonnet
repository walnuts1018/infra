local gateway = import '../envoy-gateway-class/gateway.jsonnet';
local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (labels)(app.name),
  },
  spec: {
    parentRefs: [
      {
        name: gateway.metadata.name,
        namespace: gateway.metadata.namespace,
      },
    ],
    hostnames: [
      'vrt.local.walnuts.dev',
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
        filters: [
          {
            type: 'URLRewrite',
            urlRewrite: {
              path: {
                type: 'ReplacePrefixMatch',
                replacePrefixMatch: '/',
              },
            },
          },
        ],
        backendRefs: [
          {
            kind: 'Service',
            name: (import './api/service.jsonnet').metadata.name,
            port: 3000,
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
            name: (import './ui/service.jsonnet').metadata.name,
            port: 8080,
            weight: 1,
          },
        ],
      },
    ],
  },
}
