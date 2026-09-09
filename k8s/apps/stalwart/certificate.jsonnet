local app = import 'app.json5';
{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: app.name + '-mx',
    namespace: app.namespace,
  },
  spec: {
    secretName: app.name + '-mx-tls',
    dnsNames: [
      'mx.walnuts.dev',
    ],
    issuerRef: {
      group: 'cert-manager.io',
      kind: 'ClusterIssuer',
      name: (import '../clusterissuer/letsencrypt-prod.jsonnet').metadata.name,
    },
  },
}
