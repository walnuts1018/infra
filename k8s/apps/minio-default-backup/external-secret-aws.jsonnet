std.mergePatch((import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name + '-aws-' + std.md5(std.toString($.data) + (importstr './_config/aws-credentials.tmpl'))[0:6],
  namespace: (import 'app.json5').namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'minio_biscuit_secret_key',
      remoteRef: {
        key: 'minio-default-backup',
        property: 'minio_biscuit_secret_key',
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
          credentials: (importstr './_config/aws-credentials.tmpl'),
        },
      },
    },
  },
})
