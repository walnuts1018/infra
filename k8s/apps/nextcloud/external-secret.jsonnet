(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  use_suffix: false,
  data: [
    {
      secretKey: 'admin-password',
      remoteRef: {
        key: 'nextcloud/admin_password',
      },
    },
    {
      secretKey: 'admin-username',
      remoteRef: {
        key: 'nextcloud/admin_username',
      },
    },
    {
      secretKey: 'postgres-password',
      remoteRef: {
        key: 'postgres_passwords/nextcloud',
      },
    },
    {
      secretKey: 'postgres-username',
      remoteRef: {
        key: 'nextcloud/postgres_username',
      },
    },
    {
      secretKey: 'redis-password',
      remoteRef: {
        key: 'redis/password',
      },
    },
    {
      secretKey: 'smtp-password',
      remoteRef: {
        key: 'gmail/password',
      },
    },
  ],
}
