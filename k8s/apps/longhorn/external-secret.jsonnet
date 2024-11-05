{
  apiVersion: 'external-secrets.io/v1beta1',
  kind: 'ExternalSecret',
  metadata: {
    name: 'cifs-secret',
  },
  spec: {
    secretStoreRef: {
      name: 'onepassword',
      kind: 'ClusterSecretStore',
    },
    refreshInterval: '1m',
    target: {
      name: 'cifs-secret',
    },
    data: [
      {
        secretKey: 'CIFS_PASSWORD',
        remoteRef: {
          key: 'samba',
          property: 'password',
        },
      },
      {
        secretKey: 'CIFS_USERNAME',
        remoteRef: {
          key: 'samba',
          property: 'username',
        },
      },
    ],
  },
}
