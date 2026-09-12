{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Issuer',
  metadata: {
    name: 'argocd-agent-ca',
    namespace: 'argocd',
    annotations: {
      'argocd.argoproj.io/sync-wave': '-1',
    },
  },
  spec: { ca: { secretName: 'argocd-agent-ca' } },
}
