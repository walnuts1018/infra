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
        name: (import '../envoy-gateway-class/gateway.jsonnet').metadata.name,
        namespace: (import '../envoy-gateway-class/gateway.jsonnet').metadata.namespace,
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
      },
    ],
  },
}
