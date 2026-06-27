local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';
local credentialsToml = importstr './_config/credentials.toml.tmpl';
std.mergePatch((externalSecret) {
  name: app.name + '-minio-biscuit-' + std.md5(std.toString($.data) + (credentialsToml))[0:6],
  namespace: app.namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'accessKey',
      remoteRef: {
        key: 'velero',
        property: 'access_key',
      },
    },
    {
      secretKey: 'secretKey',
      remoteRef: {
        key: 'velero',
        property: 'secret_key',
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
          credentials: (credentialsToml),
        },
      },
    },
  },
})
