std.mergePatch((import '../../components/external-secret.libsonnet') {
  use_suffix: false,
  name: (import 'app.json5').name + '-' + std.md5(std.toString($.data) + std.toString((import 'configmap.jsonnet').data))[0:6],
  data: [
    {
      secretKey: 'dbPassword',
      remoteRef: {
        key: 'misskey',
        property: 'dbpassword',
      },
    },
    {
      secretKey: 'redisPassword',
      remoteRef: {
        key: 'redis',
        property: 'password',
      },
    },
  ],
}, {
  spec: {
    target: {
      template: {
        engineVersion: 'v2',
        type: 'Opaque',
        data: {
          dbPassword: '{{ .dbPassword }}',
          redisPassword: '{{ .redisPassword }}',
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
  },
})
