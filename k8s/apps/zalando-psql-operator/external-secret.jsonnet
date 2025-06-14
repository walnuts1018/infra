{
  apiVersion: 'external-secrets.io/v1',
  kind: 'ExternalSecret',
  metadata: {
    name: 'zalando-minio',
  },
  spec: {
    secretStoreRef: {
      name: 'onepassword',
      kind: 'ClusterSecretStore',
    },
    refreshInterval: '1m',
    target: {
      name: 'zalando-minio',
    },
    data: [
      {
        secretKey: 'AWS_ACCESS_KEY_ID',
        remoteRef: {
          key: 'zalando-minio',
          property: 'access_key',
        },
      },
      {
        secretKey: 'AWS_SECRET_ACCESS_KEY',
        remoteRef: {
          key: 'zalando-minio',
          property: 'secret_key',
        },
      },
    ],
  },
}
