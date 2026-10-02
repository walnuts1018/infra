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
        name: 'envoy-gateway',
        namespace: 'envoy-gateway-system',
      },
    ],
    hostnames: ['desktop.walnuts.dev'],
    rules: [
      {
        timeouts: {
          request: '0s',
          backendRequest: '0s',
        },
        backendRefs: [
          {
            name: app.name,
            port: 8080,
          },
        ],
      },
    ],
  },
}
