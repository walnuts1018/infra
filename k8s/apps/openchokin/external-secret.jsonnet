(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'zitade-client-id',
      remoteRef: {
        key: 'openchokin/ZITADEL_CLIENT_ID',
      },
    },
    {
      secretKey: 'zitadel-client-secret',
      remoteRef: {
        key: 'openchokin/ZITADEL_CLIENT_SECRET',
      },
    },
    {
      secretKey: 'nextauth-secret',
      remoteRef: {
        key: 'openchokin/NEXTAUTH_SECRET',
      },
    },
    {
      secretKey: 'postgres-admin-password',
      remoteRef: {
        key: 'postgres_passwords/postgres',
      },
    },
    {
      secretKey: 'postgres-user-password',
      remoteRef: {
        key: 'postgres_passwords/openchokin',
      },
    },
    {
      secretKey: 'redis-password',
      remoteRef: {
        key: 'redis/password',
      },
    },
    {
      secretKey: 'cache-password',
      remoteRef: {
        key: 'openchokin/CACHE_PASSWORD',
      },
    },
  ],
}
