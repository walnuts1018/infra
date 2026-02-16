(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'client_id',
      remoteRef: {
        key: 'fitbit_manager',
        property: 'client_id',
      },
    },
    {
      secretKey: 'client_secret',
      remoteRef: {
        key: 'fitbit_manager',
        property: 'client_secret',
      },
    },
    {
      secretKey: 'cookie_secret',
      remoteRef: {
        key: 'fitbit_manager',
        property: 'cookie_secret',
      },
    },
    {
      secretKey: 'postgres_password',
      remoteRef: {
        key: 'postgres_passwords',
        property: 'fitbit_manager',
      },
    },
    {
      secretKey: 'influxdb_auth_token',
      remoteRef: {
        key: 'influxdb',
        property: 'fitbit-manager-auth-token',
      },
    },
  ],
}
