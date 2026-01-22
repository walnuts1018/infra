{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: 'pomerium-gateway',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    dnsNames: [
      '*.local.walnuts.dev',
      '*.walnuts.dev',
      'walnuts.dev',
    ],
    issuerRef: {
      group: 'cert-manager.io',
      kind: 'ClusterIssuer',
      name: (import '../clusterissuer/letsencrypt-prod.jsonnet').metadata.name,
    },
    secretName: 'pomerium-gateway-cert',
  },
}
