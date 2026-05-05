{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: 'cluster-api-provider-tart-controller-manager-ipxe',
    namespace: 'tart-infrastructure-system',
  },
  spec: {
    parentRefs: [
      {
        name: (import '../envoy-gateway-class/gateway.jsonnet').metadata.name,
        namespace: (import '../envoy-gateway-class/gateway.jsonnet').metadata.namespace,
      },
    ],
    hostnames: [
      'tart.local.walnuts.dev',
    ],
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
        backendRefs: [
          {
            name: 'cluster-api-provider-tart-controller-manager-ipxe',
            namespace: 'tart-infrastructure-system',
            port: 8082,
          },
        ],
      },
    ],
  },
}
