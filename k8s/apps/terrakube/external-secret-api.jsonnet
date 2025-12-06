(import '../../components/external-secret.libsonnet') {
  name: 'terrakube-api-secrets-overlay',
  namespace: (import 'app.json5').namespace,
  data: [
    {
      secretKey: 'patSecret',
      remoteRef: {
        key: 'terrakube',
        property: 'pat_secret',
      },
    },
    {
      secretKey: 'internalSecret',
      remoteRef: {
        key: 'terrakube',
        property: 'internal_secret',
      },
    },
    {
      secretKey: 'redisPassword',
      remoteRef: {
        key: 'terrakube',
        property: 'redis_password',
      },
    },
    {
      secretKey: 'postgresPassword',
      remoteRef: {
        key: 'postgres_passwords',
        property: 'terrakube',
      },
    },
  ],
  template_data: {
    PatSecret: '{{ .patSecret }}',
    InternalSecret: '{{ .internalSecret }}',
    TerrakubeRedisPassword: '{{ .redisPassword }}',
    DatasourcePassword: '{{ .postgresPassword }}',
  },
}
