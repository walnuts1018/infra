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
      secretKey: 'minio-secret-key',
      remoteRef: {
        key: 'seaweedfs',
        property: 'oekaki_dengon_game_secretkey',
      },
    },
  ],
  template_data: {
    'postgres-admin-password': '{{ index . "postgres-admin-password" }}',
    'postgres-user-password': '{{ index . "postgres-user-password" }}',
    'minio-secret-key': '{{ index . "minio-secret-key" }}',
    'minio-access-key': 'oekaki_dengon_game',
  },
}
