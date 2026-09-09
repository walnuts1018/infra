{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: 'argocd-agent-ca',
    namespace: 'argocd',
  },
  spec: {
    isCA: true,
    commonName: 'argocd-agent-ca',
    secretName: 'argocd-agent-ca',
    duration: '87600h',
    privateKey: { algorithm: 'ECDSA', size: 256 },
    issuerRef: { name: 'selfsigned', kind: 'ClusterIssuer', group: 'cert-manager.io' },
  },
}
