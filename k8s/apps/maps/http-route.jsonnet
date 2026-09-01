local gateway = import '../envoy-gateway-class/gateway.jsonnet';
local app = import 'app.json5';
local service = import 'service.jsonnet';

// Cloudflareを前段に挟むため、他appのmap-httproute.jsonnetと同様に
// cloudflare-proxied annotationを付ける。DNSレコードはexternal-dns-cloudflareが
// このHTTPRouteのhostnamesから自動生成する(Terraform側の変更は不要)。
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
        sectionName: 'https',
      },
    ],
    hostnames: [
      'maps.walnuts.dev',
    ],
    rules: [
      {
        backendRefs: [
          {
            kind: 'Service',
            name: service.metadata.name,
            port: 80,
            weight: 1,
          },
        ],
      },
    ],
  },
}
