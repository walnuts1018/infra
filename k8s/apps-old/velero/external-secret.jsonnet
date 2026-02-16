std.mergePatch((import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name + '-minio-biscuit-' + std.md5(std.toString($.data) + (importstr './_config/credentials.toml.tmpl'))[0:6],
  namespace: (import 'app.json5').namespace,
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
          credentials: (importstr './_config/credentials.toml.tmpl'),
        },
      },
    },
  },
})
