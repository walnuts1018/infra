local gateway = import '../envoy-gateway-class/gateway.jsonnet';
local seaweed = import '../seaweedfs-default/seaweed.jsonnet';
local app = import 'app.json5';
{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: app.name + '-usercontent',
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
      'misskeyusercontent.walnuts.dev',
    ],
    rules: [
      {
        matches: [
          {
            path: {
              type: 'PathPrefix',
              value: '/files',
            },
          },
        ],
        filters: [
          {
            type: 'URLRewrite',
            urlRewrite: {
              path: {
                type: 'ReplacePrefixMatch',
                replacePrefixMatch: '/misskey/files',
              },
            },
          },
          {
            type: 'RequestHeaderModifier',
            requestHeaderModifier: {
              add: [
                {
                  name: 'X-Forwarded-Prefix',
                  value: '/files',
                },
              ],
            },
          },
        ],
        backendRefs: [
          {
            kind: 'Service',
            name: seaweed.metadata.name + '-filer',
            namespace: seaweed.metadata.namespace,
            port: 8333,
            weight: 1,
          },
        ],
      },
    ],
  },
}
