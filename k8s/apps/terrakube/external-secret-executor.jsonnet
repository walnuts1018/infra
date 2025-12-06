(import '../../../components/external-secret.libsonnet') {
  name: 'terrakube-executor-secrets-overlay',
  namespace: (import '../app.json5').namespace,
  data: [
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
  ],
  template_data: {
    InternalSecret: '{{ .internalSecret }}',
    TerrakubeRedisPassword: '{{ .redisPassword }}',
  },
}
