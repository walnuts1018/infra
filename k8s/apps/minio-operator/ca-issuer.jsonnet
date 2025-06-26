{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Issuer',
  metadata: {
    name: (import 'app.json5').name + '-ca-issuer',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    ca: {
      secretName: (import 'app.json5').caSecretName,
    },
  },
}
