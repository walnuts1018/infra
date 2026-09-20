{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: 'argocd-agent-shared-client',
    namespace: 'argocd',
    annotations: {
      'argocd.argoproj.io/sync-wave': '0',
    },
  },
  spec: {
    commonName: 'argocd-agent-shared-client',
    secretName: 'argocd-agent-shared-client-cert',
    duration: '8760h',
    privateKey: { algorithm: 'ECDSA', size: 256 },
    issuerRef: { name: 'argocd-agent-ca', kind: 'Issuer', group: 'cert-manager.io' },
    usages: ['client auth'],
  },
}
