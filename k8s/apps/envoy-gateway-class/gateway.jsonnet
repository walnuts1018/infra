{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'Gateway',
  metadata: {
    name: 'envoy-gateway',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    gatewayClassName: (import 'gateway-class.jsonnet').metadata.name,
    listeners: [
      {
        name: 'http',
        protocol: 'HTTP',
        port: 80,
        allowedRoutes: {
          namespaces: {
            from: 'All',
          },
        },
      },
    ],
  },
}
