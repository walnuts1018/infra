{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: 'argocd-agent-ca',
    namespace: 'argocd',
    annotations: {
      'argocd.argoproj.io/sync-wave': '-2',
    },
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
