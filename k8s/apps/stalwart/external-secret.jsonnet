local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';
local config = importstr '_config/config.toml';
(externalSecret) {
  name: app.name,
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
    'config.toml': config,
  },
}
