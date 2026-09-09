{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Issuer',
  metadata: {
    name: 'argocd-agent-ca',
    namespace: 'argocd',
  },
  spec: { ca: { secretName: 'argocd-agent-ca' } },
}
