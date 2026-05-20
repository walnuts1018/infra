{
  apiVersion: 'v1',
  kind: 'ServiceAccount',
  metadata: {
    name: (import 'app.json5').name + '-gateway',
    namespace: (import 'app.json5').namespace,
  },
  imagePullSecrets: [
    {
      name: 'ghcr-login-secret',
    },
  ],
}
