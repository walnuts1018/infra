{
  env: [
    {
      name: 'USER_ID',
      value: 'B84M2S',
    },
    {
      name: 'SERVER_URL',
      value: 'https://fitbit.walnuts.dev/',
    },
    {
      name: 'CLIENT_ID',
      valueFrom: {
        secretKeyRef: {
          name: (import 'external-secret.jsonnet').spec.target.name,
          key: 'client_id',
        },
      },
    },
    {
      name: 'CLIENT_SECRET',
      valueFrom: {
        secretKeyRef: {
          name: (import 'external-secret.jsonnet').spec.target.name,
          key: 'client_secret',
        },
      },
    },
    {
      name: 'COOKIE_SECRET',
      valueFrom: {
        secretKeyRef: {
          name: (import 'external-secret.jsonnet').spec.target.name,
          key: 'cookie_secret',
        },
      },
    },
    {
      name: 'PSQL_HOST',
      value: ' postgresql-default-rw.databases.svc.cluster.local',
    },
    {
      name: 'PSQL_PORT',
      value: '5432',
    },
    {
      name: 'PSQL_DATABASE',
      value: 'fitbit_manager',
    },
    {
      name: 'PSQL_USER',
      value: 'fitbit_manager',
    },
    {
      name: 'PSQL_PASSWORD',
      valueFrom: {
        secretKeyRef: {
          name: (import 'external-secret.jsonnet').spec.target.name,
          key: 'postgres_password',
        },
      },
    },
    {
      name: 'INFLUXDB_ENDPOINT',
      value: 'http://influxdb-influxdb2.databases.svc.cluster.local',
    },
    {
      name: 'INFLUXDB_AUTH_TOKEN',
      valueFrom: {
        secretKeyRef: {
          name: (import 'external-secret.jsonnet').spec.target.name,
          key: 'influxdb_auth_token',
        },
      },
    },
    {
      name: 'INFLUXDB_ORG',
      value: 'influxdata',
    },
    {
      name: 'INFLUXDB_BUCKET',
      value: 'fitbit_manager',
    },
    {
      name: 'OTEL_EXPORTER_OTLP_ENDPOINT',
      value: 'http://default-collector.opentelemetry-collector.svc.cluster.local:4317',
    },
    {
      name: 'OTEL_EXPORTER_OTLP_INSECURE',
      value: 'true',
    },
    {
      name: 'RECORD_START_DATETIME',
      value: '2022-11-01T00:00:00Z',
    },
  ],
}
