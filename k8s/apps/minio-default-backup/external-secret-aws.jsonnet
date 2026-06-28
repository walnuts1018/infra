local app = import 'app.json5';
local awsCredentials = importstr './_config/aws-credentials.tmpl';
std.mergePatch((import '../../components/external-secret.libsonnet') {
  name: app.name + '-aws-' + std.md5(std.toString($.data) + (awsCredentials))[0:6],
  namespace: app.namespace,
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
          credentials: (awsCredentials),
        },
      },
    },
  },
})
