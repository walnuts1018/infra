local app = import 'app.json5';
local localIssuer = import 'local-issuer.jsonnet';
{
  apiVersion: 'trust.cert-manager.io/v1alpha1',
  kind: 'Bundle',
  metadata: {
    name: 'local-ca-bundle',
    namespace: app.namespace,
  },
  spec: {
    sources: [
      {
        useDefaultCAs: true,
      },
      {
        secret: {
          name: localIssuer.spec.ca.secretName,
          key: 'tls.crt',
        },
      },
    ],
    target: {
      configMap: {
        key: 'trust-bundle.pem',
      },
    },
  },
}
