local app = import 'app.json5';

function(domain) {
  apiVersion: 'gateway.envoyproxy.io/v1alpha1',
  kind: 'BackendTrafficPolicy',
  metadata: {
    name: 'argocd-server-http2',
    namespace: app.namespace,
  },
  spec: {
    targetRefs: [
      {
        group: 'gateway.networking.k8s.io',
        kind: 'GRPCRoute',
        name: 'argocd-server-grpc',
      },
    ],
    useClientProtocol: true,
  },
}
