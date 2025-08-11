(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'postgres-admin-password',
      remoteRef: {
        key: 'postgres_passwords/postgres',
      },
    },
    {
      secretKey: 'postgres-user-password',
      remoteRef: {
        key: 'postgres_passwords/oekaki_dengon_game',
      },
    },
    {
      secretKey: 'minio-access-key',
      remoteRef: {
        key: 'oekaki-dengon-game/minio-access-key',
      },
    },
    {
      secretKey: 'minio-secret-key',
      remoteRef: {
        key: 'oekaki-dengon-game/minio-secret-key',
      },
    },
  ],
}
