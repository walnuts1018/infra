{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: 'argocd-agent-client-kurumi',
    namespace: 'argocd',
  },
  spec: {
    commonName: 'kurumi',
    secretName: 'argocd-agent-client-tls-kurumi',
    duration: '8760h',
    privateKey: { algorithm: 'ECDSA', size: 256 },
    issuerRef: { name: 'argocd-agent-ca', kind: 'Issuer', group: 'cert-manager.io' },
    usages: ['client auth'],
  },
}
