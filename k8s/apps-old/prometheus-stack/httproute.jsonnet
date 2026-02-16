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
        name: (import '../pomerium-global/gateway.jsonnet').metadata.name,
        namespace: (import '../pomerium-global/gateway.jsonnet').metadata.namespace,
      },
    ],
    hostnames: [
      'prometheus.walnuts.dev',
    ],
    rules: [
      {
        backendRefs: [
          {
            kind: 'Service',
            name: 'prometheus-operated',
            port: 9090,
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
