(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'postgres_password',
      remoteRef: {
        key: 'postgres_passwords',
        property: 'stalwart',
      },
    },
    {
      secretKey: 'admin_password',
      remoteRef: {
        key: 'stalwart',
        property: 'admin_password',
      },
    },
    {
      secretKey: 's3_secret_key',
      remoteRef: {
        key: 'seaweedfs',
        property: 'stalwart_secretkey',
      },
    },
  ],
  template_data: {
    'config.toml': importstr '_config/config.toml',
  },
}
