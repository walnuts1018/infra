{
  apiVersion: 'external-secrets.io/v1',
  kind: 'ClusterSecretStore',
  metadata: {
    name: 'onepassword',
  },
  spec: {
    provider: {
      # onepasswordSDKの方が簡単に使えるけど、Daily RateLimitが厳しすぎるので自前の1Password Connect Serverを使う
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
