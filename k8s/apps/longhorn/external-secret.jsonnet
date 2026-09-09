std.mergePatch((import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name + '-backupstore-credential',
  namespace: (import 'app.json5').namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'AWS_ACCESS_KEY_ID',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'seaweedfs_biscuit_longhorn_access_key',
      },
    },
    {
      secretKey: 'AWS_SECRET_ACCESS_KEY',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'seaweedfs_biscuit_longhorn_secret_key',
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
          AWS_ACCESS_KEY_ID: '{{ .AWS_ACCESS_KEY_ID }}',
          AWS_SECRET_ACCESS_KEY: '{{ .AWS_SECRET_ACCESS_KEY }}',
          AWS_ENDPOINTS: 'https://seaweedfs-biscuit.local.walnuts.dev/',
        },
      },
    },
  },
})
