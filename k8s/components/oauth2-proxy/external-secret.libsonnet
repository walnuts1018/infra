{
  name:: error 'name is required',
  onepassword_item_name:: error 'onepassword_item_name is required',

  apiVersion: 'external-secrets.io/v1',
  kind: 'ExternalSecret',
  metadata: {
    name: $.name,
  },
  spec: {
    secretStoreRef: {
      name: 'onepassword',
      kind: 'ClusterSecretStore',
    },
    refreshInterval: '1m',
    target: {
      name: $.metadata.name,
    },
    data: [
      {
        secretKey: 'client-id',
        remoteRef: {
          key: $.onepassword_item_name + '/client-id',
        },
      },
      {
        secretKey: 'client-secret',
        remoteRef: {
          key: $.onepassword_item_name + '/client-secret',
        },
      },
      {
        secretKey: 'cookie-secret',
        remoteRef: {
          key: $.onepassword_item_name + '/cookie-secret',
        },
      },
      {
        secretKey: 'redis-password',
        remoteRef: {
          key: 'redis/password',
        },
      },
    ],
  },
}
