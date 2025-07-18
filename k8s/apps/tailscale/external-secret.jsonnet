{
  apiVersion: 'external-secrets.io/v1',
  kind: 'ExternalSecret',
  metadata: {
    name: 'tailscale-auth1',
  },
  spec: {
    secretStoreRef: {
      name: 'onepassword',
      kind: 'ClusterSecretStore',
    },
    refreshInterval: '1m',
    target: {
      name: 'tailscale-auth1',
    },
    data: [
      {
        secretKey: 'TS_AUTH_KEY',
        remoteRef: {
          key: 'tailscale',
          property: 'auth-key',
        },
      },
    ],
  },
}
