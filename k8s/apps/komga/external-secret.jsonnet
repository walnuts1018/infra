std.mergePatch((import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'clientsecret',
      remoteRef: {
        key: 'komga',
        property: 'client-secret',
      },
    },
  ],
}, {
  spec: {
    target: {
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
                  key: 'application.yml',
                  templateAs: 'Values',
                },
              ],
            },
          },
        ],
      },
    },
  },
})
