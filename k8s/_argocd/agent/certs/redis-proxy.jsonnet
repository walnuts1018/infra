{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: 'argocd-agent-redis-proxy-tls',
    namespace: 'argocd',
  },
  spec: {
    commonName: 'argocd-agent-redis-proxy',
    secretName: 'argocd-redis-proxy-tls',
    duration: '8760h',
    privateKey: { algorithm: 'ECDSA', size: 256 },
    issuerRef: { name: 'argocd-agent-ca', kind: 'Issuer', group: 'cert-manager.io' },
    dnsNames: [
      'argocd-agent-redis-proxy',
      'argocd-agent-redis-proxy.argocd.svc',
      'argocd-agent-redis-proxy.argocd.svc.cluster.local',
    ],
    usages: ['server auth'],
  },
}
