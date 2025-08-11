{
  apiVersion: 'external-secrets.io/v1',
  kind: 'ClusterSecretStore',
  metadata: {
    name: 'onepassword',
  },
  spec: {
    provider: {
      onepasswordSDK: {
        vault: 'kurumi',
        auth: {
          serviceAccountSecretRef: {
            name: 'onepassword-connect-token-kurumi',
            namespace: 'external-secrets',
            key: 'token',
          },
        },
      },
    },
  },
}
