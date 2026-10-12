{
  apiVersion: 'external-secrets.io/v1',
  kind: 'ExternalSecret',
  metadata: {
    name: 'ghcr-login-secret',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    refreshInterval: '1h',
    secretStoreRef: {
      name: 'onepassword',
      kind: 'ClusterSecretStore',
    },
    target: {
      name: 'ghcr-login-secret',
      template: {
        type: 'kubernetes.io/dockerconfigjson',
      },
    },
    data: [
      {
        secretKey: '.dockerconfigjson',
        remoteRef: {
          key: 'github',
          property: '.dockerconfigjson',
        },
      },
    ],
  },
}
