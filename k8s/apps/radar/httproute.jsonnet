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
    hostnames: ['k8s-dashboard.walnuts.dev'],
    rules: [
      {
        backendRefs: [
          {
            name: 'keda-add-ons-http-interceptor-proxy',
            namespace: 'keda',
            port: 8080,
          },
        ],
      },
    ],
  },
}
