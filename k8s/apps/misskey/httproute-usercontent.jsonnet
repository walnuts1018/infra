{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: (import 'app.json5').name + '-usercontent',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    parentRefs: [
      {
        name: (import '../envoy-gateway-class/gateway.jsonnet').metadata.name,
        namespace: (import '../envoy-gateway-class/gateway.jsonnet').metadata.namespace,
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
            name: (import '../seaweedfs-default/seaweed.jsonnet').metadata.name + '-filer',
            namespace: (import '../seaweedfs-default/seaweed.jsonnet').metadata.namespace,
            port: 8333,
            weight: 1,
          },
        ],
      },
    ],
  },
}
