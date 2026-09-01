local gateway = import '../envoy-gateway-class/gateway.jsonnet';
local seaweed = import '../seaweedfs-default/seaweed.jsonnet';
local app = import 'app.json5';

local seaweedS3DomainName = 'seaweedfs.local.walnuts.dev';

// cloudflareを挟みたいのでHTTPRouteを分ける
{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: app.name + '-map',
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
      'picca-map.walnuts.dev',
    ],
    rules: [
      {
        matches: [
          {
            path: {
              type: 'PathPrefix',
              value: '/basemap',
            },
          },
        ],
        filters: [
          {
            type: 'URLRewrite',
            urlRewrite: {
              hostname: seaweedS3DomainName,
              path: {
                type: 'ReplacePrefixMatch',
                replacePrefixMatch: '/' + app.name + '/basemap',
              },
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
      {
        matches: [
          {
            path: {
              type: 'PathPrefix',
              value: '/fonts',
            },
          },
        ],
        filters: [
          {
            type: 'URLRewrite',
            urlRewrite: {
              hostname: seaweedS3DomainName,
              path: {
                type: 'ReplacePrefixMatch',
                replacePrefixMatch: '/' + app.name + '/fonts',
              },
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
