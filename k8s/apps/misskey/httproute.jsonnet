local gateway = import '../envoy-gateway-class/gateway.jsonnet';
local app = import 'app.json5';
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
