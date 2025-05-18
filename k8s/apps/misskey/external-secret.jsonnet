{
  apiVersion: 'external-secrets.io/v1',
  kind: 'ExternalSecret',
  metadata: {
    name: (import 'app.json5').name,
  },
  spec: {
    secretStoreRef: {
      name: 'onepassword',
      kind: 'ClusterSecretStore',
    },
    refreshInterval: '1m',
    target: {
      name: $.metadata.name,
      template: {
        engineVersion: 'v2',
        type: 'Opaque',
        data: {
          misskeydbpassword: '{{ .misskeydbpassword }}',
          redispassword: '{{ .redispassword }}',
        },
        templateFrom: [
          {
            target: 'Data',
            configMap: {
              name: (import 'configmap.jsonnet').metadata.name,
              items: [
                {
                  key: 'default.yml',
                  templateAs: 'Values',
                },
              ],
            },
          },
        ],
      },
    },
    data: [
      {
        secretKey: 'misskeydbpassword',
        remoteRef: {
          key: 'postgres_passwords',
          property: 'misskey',
        },
      },
      {
        secretKey: 'redispassword',
        remoteRef: {
          key: 'redis',
          property: 'password',
        },
      },
    ],
  },
}
