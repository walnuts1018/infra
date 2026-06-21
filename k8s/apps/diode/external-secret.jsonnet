[
  (import '../../components/external-secret.libsonnet') {
    name: 'diode',
    namespace: (import 'app.json5').namespace,
    use_suffix: false,
    data: [
      {
        secretKey: 'db_password',
        remoteRef: {
          key: 'postgres_passwords',
          property: 'diode',
        },
      },
      {
        secretKey: 'redis_password',
        remoteRef: {
          key: 'diode',
          property: 'redis_password',
        },
      },
      {
        secretKey: 'diode_to_netbox_client_secret',
        remoteRef: {
          key: 'diode',
          property: 'diode_to_netbox_client_secret',
        },
      },
    ],
    template_data: {
      'db-password': '{{ .db_password }}',
      'redis-password': '{{ .redis_password }}',
      POSTGRES_PASSWORD: '{{ .db_password }}',
      REDIS_PASSWORD: '{{ .redis_password }}',
      DIODE_TO_NETBOX_CLIENT_SECRET: '{{ .diode_to_netbox_client_secret }}',
    },
  },
  (import '../../components/external-secret.libsonnet') {
    name: 'diode-auth-oauth2-secret',
    namespace: (import 'app.json5').namespace,
    use_suffix: false,
    data: [
      {
        secretKey: 'diode_ingest_client_secret',
        remoteRef: {
          key: 'diode',
          property: 'diode_ingest_client_secret',
        },
      },
      {
        secretKey: 'diode_to_netbox_client_secret',
        remoteRef: {
          key: 'diode',
          property: 'diode_to_netbox_client_secret',
        },
      },
      {
        secretKey: 'netbox_to_diode_client_secret',
        remoteRef: {
          key: 'diode',
          property: 'netbox_to_diode_client_secret',
        },
      },
    ],
    template_data: {
      'client-credentials.json': (importstr './_config/client-credentials.json'),
    },
  },
]
