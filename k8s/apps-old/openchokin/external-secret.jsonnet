(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'zitade-client-id',
      remoteRef: {
        key: 'openchokin',
        property: 'ZITADEL_CLIENT_ID',
      },
    },
    {
      secretKey: 'zitadel-client-secret',
      remoteRef: {
        key: 'openchokin',
        property: 'ZITADEL_CLIENT_SECRET',
      },
    },
    {
      secretKey: 'nextauth-secret',
      remoteRef: {
        key: 'openchokin',
        property: 'NEXTAUTH_SECRET',
      },
    },
    {
      secretKey: 'postgres-admin-password',
      remoteRef: {
        key: 'postgres_passwords',
        property: 'postgres',
      },
    },
    {
      secretKey: 'postgres-user-password',
      remoteRef: {
        key: 'postgres_passwords',
        property: 'openchokin',
      },
    },
    {
      secretKey: 'redis-password',
      remoteRef: {
        key: 'redis',
        property: 'password',
      },
    },
    {
      secretKey: 'cache-password',
      remoteRef: {
        key: 'openchokin',
        property: 'CACHE_PASSWORD',
      },
    },
  ],
}
