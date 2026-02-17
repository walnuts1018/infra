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
      secretKey: 'hashed_admin_secret',
      remoteRef: {
        key: 'stalwart',
        property: 'hashed_admin_secret',
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
