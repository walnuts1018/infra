{
  apiVersion: 'external-secrets.io/v1',
  kind: 'ClusterSecretStore',
  metadata: {
    name: 'onepassword',
  },
  spec: {
    provider: {
      onepasswordSDK: {
        vaults: 'kurumi',
        auth: {
          serviceAccountSecretRef: {
            name: 'onepassword-connect-token-kurumi',
            key: 'token',
          },
        },
      },
    },
  },
}
