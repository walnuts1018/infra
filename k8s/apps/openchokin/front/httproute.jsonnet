local gateway = import '../../envoy-gateway-class/gateway.jsonnet';
local app = import '../app.json5';
{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: app.name + '-front',
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
      'openchokin.walnuts.dev',
    ],
    rules: [
      {
        backendRefs: [
          {
            kind: 'Service',
            name: (import './service.jsonnet').metadata.name,
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
        ],
      },
    ],
  },
}
