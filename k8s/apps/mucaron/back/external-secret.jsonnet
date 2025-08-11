(import '../../../components/external-secret.libsonnet') {
  name: (import '../app.json5').name,
  data: [
    {
      secretKey: 'postgres_password',
      remoteRef: {
        key: 'postgres_passwords',
        property: 'mucaron',
      },
    },
    {
      secretKey: 'redis_password',
      remoteRef: {
        key: 'redis',
        property: 'password',
      },
    },
    {
      secretKey: 'session_secret',
      remoteRef: {
        key: 'mucaron',
        property: 'session_secret',
      },
    },
    {
      secretKey: 'minio_secret_key',
      remoteRef: {
        key: 'mucaron',
        property: 'minio_secret_key',
      },
    },
  ],
}
