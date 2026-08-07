local app = import '../pinniped/app.json5';

{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    dnsNames: ['kurumi-pinniped.local.walnuts.dev'],
    issuerRef: {
      group: 'cert-manager.io',
      kind: 'ClusterIssuer',
      name: (import '../clusterissuer/letsencrypt-prod.jsonnet').metadata.name,
    },
    secretName: app.name + '-tls',
  },
}
