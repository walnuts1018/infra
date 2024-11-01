{
  apiVersion: 'external-secrets.io/v1beta1',
  kind: 'ExternalSecret',
  metadata: {
    name: (import '../app.json5').backend.name,
  },
  spec: {
    secretStoreRef: {
      name: 'onepassword',
      kind: 'ClusterSecretStore',
    },
    refreshInterval: '1m',
    target: {
      name: (import '../app.json5').backend.name,
    },
    data: [
      {
        secretKey: 'postgres_password',
        remoteRef: {
          key: 'postgres_passwords',
          property: 'ac-hacking',
        },
      },
    ],
  },
}
