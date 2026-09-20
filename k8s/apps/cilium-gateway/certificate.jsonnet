local app = import 'app.json5';
{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: 'seaweedfs-biscuit-tls',
    namespace: app.namespace,
  },
  spec: {
    secretName: 'seaweedfs-biscuit-tls',
    dnsNames: [
      'seaweedfs-biscuit.local.walnuts.dev',
    ],
    issuerRef: {
      name: 'letsencrypt-prod',
      kind: 'ClusterIssuer',
      group: 'cert-manager.io',
    },
  },
}
