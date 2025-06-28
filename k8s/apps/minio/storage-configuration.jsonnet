std.mergePatch((import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name + '-storage-config-' + std.md5(std.toString($.data) + (importstr './config/storage-configuration.tmpl'))[0:6],
  namespace: (import 'app.json5').namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'rootUser',
      remoteRef: {
        key: 'minio',
        property: 'rootUser',
      },
    },
    {
      secretKey: 'rootPassword',
      remoteRef: {
        key: 'minio',
        property: 'rootPassword',
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
          'config.env': (importstr './config/storage-configuration.tmpl'),
        },
      },
    },
  },
})
