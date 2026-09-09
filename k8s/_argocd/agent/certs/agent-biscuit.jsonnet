{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: 'argocd-agent-client-biscuit',
    namespace: 'argocd',
  },
  spec: {
    commonName: 'biscuit',
    secretName: 'argocd-agent-client-tls-biscuit',
    duration: '8760h',
    privateKey: { algorithm: 'ECDSA', size: 256 },
    issuerRef: { name: 'argocd-agent-ca', kind: 'Issuer', group: 'cert-manager.io' },
    usages: ['client auth'],
  },
}
