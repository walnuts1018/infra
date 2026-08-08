local app = import 'app.json5';
function(domain) {
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'BackendTLSPolicy',
  metadata: {
    name: 'argocd-server-tls',
    namespace: app.namespace,
  },
  spec: {
    targetRefs: [
      {
        group: '',
        kind: 'Service',
        name: 'argocd-server',
      },
    ],
    validation: {
      hostname: domain,
      wellKnownCACertificates: 'System',
    },
  },
}
