std.mergePatch((import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name + '-backupstore-credential',
  data: [
    {
      secretKey: 'AWS_SECRET_ACCESS_KEY',
      remoteRef: {
        key: 'longhorn',
        property: 'minio_secret_key',
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
          AWS_ACCESS_KEY_ID: 'abaQ84KgJMyEtxZzW3RW',
          AWS_SECRET_ACCESS_KEY: '{{ .AWS_SECRET_ACCESS_KEY }}',
          AWS_ENDPOINTS: 'http://minio-biscuit.local.walnuts.dev/',
        },
      },
    },
  },
})
