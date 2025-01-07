(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
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
        property: 'oekaki_dengon_game',
      },
    },
    {
      secretKey: 'minio-access-key',
      remoteRef: {
        key: 'oekaki-dengon-game',
        property: 'minio-access-key',
      },
    },
    {
      secretKey: 'minio-secret-key',
      remoteRef: {
        key: 'oekaki-dengon-game',
        property: 'minio-secret-key',
      },
    },
  ],
}
