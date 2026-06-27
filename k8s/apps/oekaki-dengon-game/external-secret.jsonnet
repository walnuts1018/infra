local app = import 'app.json5';
(import '../../components/external-secret.libsonnet') {
  name: app.name,
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
      secretKey: 'minio-secret-key',
      remoteRef: {
        key: 'seaweedfs',
        property: 'oekaki_dengon_game_secretkey',
      },
    },
  ],
}
