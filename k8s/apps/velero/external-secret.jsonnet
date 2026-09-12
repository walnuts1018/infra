local app = import 'app.json5';
local credentialsToml = importstr './_config/credentials.toml.tmpl';
std.mergePatch((import '../../components/external-secret.libsonnet') {
  name: app.name + '-seaweedfs-biscuit',
  namespace: app.namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'accessKey',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'seaweedfs_biscuit_velero_access_key',
      },
    },
    {
      secretKey: 'secretKey',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'seaweedfs_biscuit_velero_secret_key',
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
