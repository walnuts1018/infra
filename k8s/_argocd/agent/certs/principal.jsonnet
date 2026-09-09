{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: 'argocd-agent-principal-tls',
    namespace: 'argocd',
    annotations: {
      'argocd.argoproj.io/sync-wave': '0',
    },
  },
  spec: {
    commonName: 'argocd-agent',
    secretName: 'argocd-agent-principal-tls',
    duration: '8760h',
    privateKey: { algorithm: 'ECDSA', size: 256 },
    issuerRef: { name: 'argocd-agent-ca', kind: 'Issuer', group: 'cert-manager.io' },
    dnsNames: [
      'argocd-agent',
      'argocd-agent.argocd.svc',
      'argocd-agent.argocd.svc.cluster.local',
      'argocd-agent.local.walnuts.dev',
    ],
    usages: ['server auth'],
  },
}
