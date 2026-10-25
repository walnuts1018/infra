(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name + '-backup',
  data: [
    {
      secretKey: 'b2_account_id',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'mcl-playground-backup-application-key-id',
      },
    },
    {
      secretKey: 'b2_account_key',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'mcl-playground-backup-application-key',
      },
    },
  ],
  template_data: {
    RCLONE_CONFIG_B2_ACCOUNT: '{{ .b2_account_id }}',
    RCLONE_CONFIG_B2_KEY: '{{ .b2_account_key }}',
  },
}
