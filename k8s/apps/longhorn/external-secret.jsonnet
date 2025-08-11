{
  apiVersion: 'external-secrets.io/v1',
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
          key: 'samba/password',
        },
      },
      {
        secretKey: 'CIFS_USERNAME',
        remoteRef: {
          key: 'samba/username',
        },
      },
    ],
  },
}
