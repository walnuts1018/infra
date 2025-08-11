(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  use_suffix: false,
  data: [
    {
      secretKey: 'admin-password',
      remoteRef: {
        key: 'nextcloud',
        property: 'admin_password',
      },
    },
    {
      secretKey: 'admin-username',
      remoteRef: {
        key: 'nextcloud',
        property: 'admin_username',
      },
    },
    {
      secretKey: 'postgres-password',
      remoteRef: {
        key: 'postgres_passwords',
        property: 'nextcloud',
      },
    },
    {
      secretKey: 'postgres-username',
      remoteRef: {
        key: 'nextcloud',
        property: 'postgres_username',
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
      secretKey: 'smtp-password',
      remoteRef: {
        key: 'gmail',
        property: 'password',
      },
    },
  ],
}
