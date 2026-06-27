local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';
local storageConfiguration = importstr './config/storage-configuration.tmpl';
std.mergePatch((externalSecret) {
  name: app.name + '-storage-config-' + std.md5(std.toString($.data) + (storageConfiguration))[0:6],
  namespace: app.namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'rootUser',
      remoteRef: {
        key: 'minio-biscuit',
        property: 'rootUser',
      },
    },
    {
      secretKey: 'rootPassword',
      remoteRef: {
        key: 'minio-biscuit',
        property: 'rootPassword',
      },
    },
    {
      secretKey: 'clientSecret',
      remoteRef: {
        key: 'minio-biscuit',
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
        data: {
          'config.env': (storageConfiguration),
        },
      },
    },
  },
})
