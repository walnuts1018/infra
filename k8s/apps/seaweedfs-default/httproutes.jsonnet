local gateway = import '../envoy-gateway-class/gateway.jsonnet';
local app = import 'app.json5';
local seaweed = import 'seaweed.jsonnet';

local route(name, hostname) = {
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: name,
    namespace: app.namespace,
  },
  spec: {
    parentRefs: [
      {
        name: gateway.metadata.name,
        namespace: gateway.metadata.namespace,
      },
    ],
    hostnames: [hostname],
    rules: [
      {
        backendRefs: [
          {
            kind: 'Service',
            name: seaweed.metadata.name + '-filer',
            port: 8333,
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
        timeouts: {
          request: '1h',
        },
      },
    ],
  },
};

[
  route(app.name, 'seaweedfs.walnuts.dev'),
  route(app.name + '-local', 'seaweedfs.local.walnuts.dev'),
  {
    apiVersion: 'gateway.networking.k8s.io/v1',
    kind: 'HTTPRoute',
    metadata: {
      name: app.name + '-minio',
      namespace: app.namespace,
    },
    spec: {
      parentRefs: [
        {
          name: gateway.metadata.name,
          namespace: gateway.metadata.namespace,
        },
      ],
      hostnames: ['minio.walnuts.dev'],
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
          filters: [
            {
              type: 'RequestRedirect',
              requestRedirect: {
                scheme: 'https',
                statusCode: 301,
                hostname: 'seaweedfs.walnuts.dev',
              },
            },
          ],
        },
      ],
    },
  },
]
