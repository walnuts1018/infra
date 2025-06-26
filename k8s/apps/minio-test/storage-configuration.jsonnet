std.mergePatch((import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name + '-storage-config',
  namespace: (import 'app.json5').namespace,
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
    {
      secretKey: 'client-secret',
      remoteRef: {
        key: 'minio',
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
          'config.env': (importstr './config/storage-configuration.tmpl'),
        },
      },
    },
  },
})
