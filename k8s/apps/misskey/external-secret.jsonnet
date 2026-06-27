local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';
local configmap = import 'configmap.jsonnet';
std.mergePatch((externalSecret) {
  use_suffix: false,
  name: app.name + '-' + std.md5(std.toString($.data) + std.toString(configmap.data))[0:6],
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
              name: configmap.metadata.name,
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
