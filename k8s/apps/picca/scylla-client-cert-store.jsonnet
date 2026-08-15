local app = import 'app.json5';
local sa = import 'scylla-client-cert-sa.jsonnet';
{
  apiVersion: 'external-secrets.io/v1',
  kind: 'SecretStore',
  metadata: {
    name: 'scylla-client-cert',
    namespace: app.namespace,
  },
  spec: {
    provider: {
      kubernetes: {
        remoteNamespace: 'databases',
        // serverを省略するとクラスタ内のAPIサーバーに接続する
        auth: {
          serviceAccount: {
            name: sa.metadata.name,
            namespace: sa.metadata.namespace,
          },
        },
      },
    },
  },
}
