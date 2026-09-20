local app = import 'app.json5';
local awsCredentials = importstr './_config/aws-credentials.tmpl';
std.mergePatch((import '../../components/external-secret.libsonnet') {
  name: app.name + '-aws-' + std.md5(std.toString($.data) + (awsCredentials))[0:6],
  namespace: app.namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'seaweedfs_biscuit_default_backup_access_key',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'seaweedfs_biscuit_default_backup_access_key',
      },
    },
    {
      secretKey: 'seaweedfs_biscuit_default_backup_secret_key',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'seaweedfs_biscuit_default_backup_secret_key',
      },
    },
    {
      secretKey: 'b2_seaweedfs_application_key_id',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'b2-seaweedfs-application-key-id',
      },
    },
    {
      secretKey: 'b2_seaweedfs_application_key',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'b2-seaweedfs-application-key',
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
