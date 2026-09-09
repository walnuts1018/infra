local app = import 'app.json5';

function(domain) {
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'HTTPRoute',
  metadata: {
    name: 'argocd-server-grpc',
    namespace: app.namespace,
  },
  spec: {
    parentRefs: [
      {
        name: 'envoy-gateway',
        namespace: 'envoy-gateway-system',
      },
    ],
    hostnames: [domain],
    rules: [
      {
        matches: [
          {
            headers: [
              {
                name: 'Content-Type',
                type: 'RegularExpression',
                value: '^application/grpc.*',
              },
            ],
          },
        ],
        backendRefs: [
          {
            name: 'argocd-server-grpc',
            port: 80,
          },
        ],
      },
    ],
  },
}
