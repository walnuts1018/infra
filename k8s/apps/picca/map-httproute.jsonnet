local gateway = import '../envoy-gateway-class/gateway.jsonnet';
local seaweed = import '../seaweedfs-default/seaweed.jsonnet';
local app = import 'app.json5';
local martinService = import 'martin/service.jsonnet';

local seaweedS3DomainName = 'seaweedfs.local.walnuts.dev';

// TileJSON(GET /basemap、path exact一致)とMVT(GET /basemap/{z}/{x}/{y}、path prefix
// 一致)で異なるCache-Controlを設定する(docs/tasks/00291-map.md 8章)。TileJSONは
// tileset versionを発見する入口なので短いmax-age、version付きMVTは内容が不変なので
// 長期immutable cacheにする。Cloudflare cache purge APIは使わず、この2段構えの
// Cache-Control + MartinのTileJSON version埋め込みだけで更新を反映する。
local tileJsonResponseHeaders = {
  type: 'ResponseHeaderModifier',
  responseHeaderModifier: {
    set: [{ name: 'Cache-Control', value: 'public, max-age=60' }],
  },
};
local tileResponseHeaders = {
  type: 'ResponseHeaderModifier',
  responseHeaderModifier: {
    set: [{ name: 'Cache-Control', value: 'public, max-age=31536000, immutable' }],
  },
};

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
        // TileJSON。MartinのソースIDが`basemap`(PMTilesファイル名`basemap.pmtiles`の
        // stem)なので、exact一致でTileJSONエンドポイントだけを通す。
        matches: [
          {
            path: {
              type: 'Exact',
              value: '/basemap',
            },
          },
        ],
        filters: [tileJsonResponseHeaders],
        backendRefs: [
          {
            kind: 'Service',
            name: martinService.metadata.name,
            namespace: app.namespace,
            port: 80,
            weight: 1,
          },
        ],
      },
      {
        // XYZ MVT。
        matches: [
          {
            path: {
              type: 'PathPrefix',
              value: '/basemap/',
            },
          },
        ],
        filters: [tileResponseHeaders],
        backendRefs: [
          {
            kind: 'Service',
            name: martinService.metadata.name,
            namespace: app.namespace,
            port: 80,
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
