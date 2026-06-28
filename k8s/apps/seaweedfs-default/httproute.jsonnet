local gateway = import '../envoy-gateway-class/gateway.jsonnet';
local app = import 'app.json5';
{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    parentRefs: [
      {
        name: gateway.metadata.name,
        namespace: gateway.metadata.namespace,
      },
    ],
    hostnames: [
      'seaweedfs.walnuts.dev',
    ],
    rules: [
      {
        backendRefs: [
          {
            kind: 'Service',
            name: 'seaweedfs-default-filer',
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
}
