local gateway = import '../envoy-gateway-class/gateway.jsonnet';
local app = import 'app.json5';
local seaweed = import '../seaweedfs-default/seaweed.jsonnet';

// basemap-updater(backend/cmd/basemap-updater)がpiccaバケット直下のbasemap/・fonts/
// prefixへ配置するMVTタイル/フォントを、CloudflareのCDNキャッシュ経由で配信する専用route。
// 外部にCDN cache purgeの仕組みは無いため、更新の反映は各objectのCache-Control
// (max-age短め+must-revalidate、docs/tasks/00291-map.md 8章参照)による自然な
// 再検証に委ねる設計。
//
// seaweedfs.walnuts.devと違いこのhostnameはfiler s3.domainNameと一致しないため、
// S3 API(要認証)ではなくfilerネイティブのHTTP GETとして扱われ、認証なしで配信できる
// (misskeyのusercontent配信と同じ仕組み。misskey/httproute-usercontent.jsonnet参照)。
{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: app.name + '-map-cdn',
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
