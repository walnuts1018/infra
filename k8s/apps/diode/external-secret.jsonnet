local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';
local clientCredentials = importstr './_config/client-credentials.json';
[
  (externalSecret) {
    name: 'diode',
    namespace: app.namespace,
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
  (externalSecret) {
    name: 'diode-hydra-secret',
    namespace: app.namespace,
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
        secretKey: 'hydra_secrets_system',
        remoteRef: {
          key: 'diode',
          property: 'hydra_secrets_system',
        },
      },
      {
        secretKey: 'hydra_secrets_cookie',
        remoteRef: {
          key: 'diode',
          property: 'hydra_secrets_cookie',
        },
      },
    ],
    template_data: {
      dsn: 'postgres://diode:{{ .db_password | urlquery }}@postgresql-default-rw.databases.svc.cluster.local:5432/diode?sslmode=disable',
      secretsSystem: '{{ .hydra_secrets_system }}',
      secretsCookie: '{{ .hydra_secrets_cookie }}',
    },
  },
  (externalSecret) {
    name: 'diode-auth-oauth2-secret',
    namespace: app.namespace,
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
      'client-credentials.json': (clientCredentials),
    },
  },
]
