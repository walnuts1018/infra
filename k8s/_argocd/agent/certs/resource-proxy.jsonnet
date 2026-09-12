{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: 'argocd-agent-resource-proxy-tls',
    namespace: 'argocd',
    annotations: {
      'argocd.argoproj.io/sync-wave': '0',
    },
  },
  spec: {
    commonName: 'argocd-agent-resource-proxy',
    secretName: 'argocd-agent-resource-proxy-tls',
    duration: '8760h',
    privateKey: { algorithm: 'ECDSA', size: 256 },
    issuerRef: { name: 'argocd-agent-ca', kind: 'Issuer', group: 'cert-manager.io' },
    dnsNames: [
      'argocd-agent-resource-proxy',
      'argocd-agent-resource-proxy.argocd.svc',
      'argocd-agent-resource-proxy.argocd.svc.cluster.local',
    ],
    usages: ['server auth'],
  },
}
