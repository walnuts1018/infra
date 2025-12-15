{
  apiVersion: 'gateway.envoyproxy.io/v1alpha1',
  kind: 'BackendTrafficPolicy',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    targetRefs: [
      {
        group: 'gateway.networking.k8s.io',
        kind: 'HTTPRoute',
        name: (import 'httproute.jsonnet').metadata.name,
      },
    ],
    rateLimit: {
      type: 'Global',
      global: {
        rules: [
          {
            clientSelectors: [
              {
                headers: [
                  {
                    name: 'Cf-Connecting-Ip',
                    type: 'Distinct',
                  },
                ],
              },
              {
                path: {
                  type: 'PathPrefix',
                  value: '/api/',
                },
              },
            ],
            limit: {
              requests: 60,
              unit: 'Hour',
            },
          },
        ],
      },
    },
  },
}
