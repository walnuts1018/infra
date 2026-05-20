{
  apiVersion: 'v1',
  kind: 'ServiceAccount',
  metadata: {
    name: 'picca-ai-prototype-debug-web',
    namespace: (import 'app.json5').namespace,
  },
  imagePullSecrets: [
    {
      name: 'ghcr-login-secret',
    },
  ],
}
