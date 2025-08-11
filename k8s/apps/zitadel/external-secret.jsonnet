{
  apiVersion: 'external-secrets.io/v1',
  kind: 'ExternalSecret',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
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
        templateFrom: [
          {
            target: 'Data',
            configMap: {
              name: (import 'configmap.jsonnet').metadata.name,
              items: [
                {
                  key: 'config.yaml',
                  templateAs: 'Values',
                },
              ],
            },
          },
        ],
        data: {
          masterkey: '{{ .masterkey }}',
          postgres: '{{ .postgresdbpassword }}',
        },
      },
    },
    data: [
      {
        secretKey: 'masterkey',
        remoteRef: {
          key: 'zitadel',
          property: 'masterkey',
        },
      },
      {
        secretKey: 'postgresdbpassword',
        remoteRef: {
          key: 'postgres_passwords',
          property: 'postgres',
        },
      },
      {
        secretKey: 'zitadeldbpassword',
        remoteRef: {
          key: 'postgres_passwords',
          property: 'zitadel',
        },
      },
    ],
  },
}
