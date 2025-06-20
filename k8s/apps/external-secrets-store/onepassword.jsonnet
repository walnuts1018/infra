{
  apiVersion: 'external-secrets.io/v1',
  kind: 'ClusterSecretStore',
  metadata: {
    name: 'onepassword',
  },
  spec: {
    provider: {
      onepassword: {
        connectHost: 'http://onepassword-connect.onepassword.svc.cluster.local:8080',
        vaults: {
          kurumi: 1,
        },
        auth: {
          secretRef: {
            connectTokenSecretRef: {
              namespace: 'onepassword',
              name: 'onepassword-token',
              key: 'token',
            },
          },
        },
      },
    },
  },
}
