(import '../../../components/external-secret.libsonnet') {
  name: (import '../app.json5').name,
  data: [
    {
      secretKey: 'postgres_password',
      remoteRef: {
        key: 'postgres_passwords/mucaron',
      },
    },
    {
      secretKey: 'redis_password',
      remoteRef: {
        key: 'redis/password',
      },
    },
    {
      secretKey: 'session_secret',
      remoteRef: {
        key: 'mucaron/session_secret',
      },
    },
    {
      secretKey: 'minio_secret_key',
      remoteRef: {
        key: 'mucaron/minio_secret_key',
      },
    },
  ],
}
