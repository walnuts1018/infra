local app = import 'app.json5';
{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: 'seaweedfs-biscuit-s3',
    namespace: app.namespace,
  },
  spec: {
    parentRefs: [
      {
        name: 'cilium-gateway',
        namespace: 'cilium-system',
      },
    ],
    hostnames: [
      'seaweedfs-biscuit.local.walnuts.dev',
    ],
    rules: [
      {
        backendRefs: [
          {
            kind: 'Service',
            name: app.name,
            port: 8333,
          },
        ],
        timeouts: {
          request: '1h',
        },
      },
    ],
  },
}
