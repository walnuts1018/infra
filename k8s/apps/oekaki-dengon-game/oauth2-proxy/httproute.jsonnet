{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    parentRefs: [
      {
        name: (import '../../pomerium-global/gateway.jsonnet').metadata.name,
        namespace: (import '../../pomerium-global/gateway.jsonnet').metadata.namespace,
      },
    ],
    hostnames: [
      'oekaki.walnuts.dev',
    ],
    // TODO: robots.txt
    rules: [
      {
        matches: [
          {
            path: {
              type: 'PathPrefix',
              value: '/public',
            },
          },
          {
            path: {
              type: 'PathPrefix',
              value: '/api',
            },
            method: 'GET',
          },
          {
            path: {
              type: 'PathPrefix',
              value: '/_next',
            },
          },
          {
            path: {
              type: 'PathPrefix',
              value: '/texture.png',
            },
          },
          {
            path: {
              type: 'PathPrefix',
              value: '/favicon.ico',
            },
          },
          {
            path: {
              type: 'PathPrefix',
              value: '/site.webmanifest',
            },
          },
        ],
        backendRefs: [
          {
            kind: 'Service',
            name: 'oekaki-dengon-game-front',
            port: 3000,
            weight: 1,
          },
        ],
        filters: [
          {
            type: 'ExtensionRef',
            extensionRef: {
              group: 'gateway.pomerium.io',
              kind: 'PolicyFilter',
              name: (import 'policy-filter-public.jsonnet').metadata.name,
            },
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
            name: 'oekaki-dengon-game-front',
            port: 3000,
            weight: 1,
          },
        ],
        filters: [
          {
            type: 'ExtensionRef',
            extensionRef: {
              group: 'gateway.pomerium.io',
              kind: 'PolicyFilter',
              name: (import 'policy-filter.jsonnet').metadata.name,
            },
          },
        ],
      },
    ],
  },
}
