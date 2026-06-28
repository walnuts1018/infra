local gateway = import '../envoy-gateway-class/gateway.jsonnet';
local app = import 'app.json5';
{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: app.name + '-www',
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
              statusCode: 301,
            },
          },
        ],
      },
    ],
  },
}
