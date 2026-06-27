{
  apiVersion: 'trust.cert-manager.io/v1alpha1',
  kind: 'Bundle',
  metadata: {
    name: 'local-ca-bundle',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    sources: [
      {
        useDefaultCAs: true,
      },
      {
        secret: {
          name: (import 'local-issuer.jsonnet').spec.ca.secretName,
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
