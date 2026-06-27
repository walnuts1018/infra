local gateway = import '../pomerium-global/gateway.jsonnet';
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
      'warrior.walnuts.dev',
    ],
    rules: [
      {
        backendRefs: [
          {
            kind: 'Service',
            name: 'warrior',
            port: 8001,
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
