local letsencryptProd = import '../clusterissuer/letsencrypt-prod.jsonnet';
local app = import 'app.json5';
{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: 'envoy-gateway',
    namespace: app.namespace,
  },
  spec: {
    dnsNames: [
      '*.local.walnuts.dev',
      '*.walnuts.dev',
      'walnuts.dev',
      '*.waln.uk',
    ],
    issuerRef: {
      group: 'cert-manager.io',
      kind: 'ClusterIssuer',
      name: letsencryptProd.metadata.name,
    },
    secretName: 'envoy-gateway-cert',
  },
}
