(import '../../components/external-secret.libsonnet') {
  name: 'tempo-credentials',
  data: [
    {
      secretKey: 'MINIO_ACCESS_KEY',
      remoteRef: {
        key: 'tempo',
        property: 'minio_access_key',
      },
    },
    {
      secretKey: 'MINIO_SECRET_KEY',
      remoteRef: {
        key: 'tempo',
        property: 'minio_secret_key',
      },
    },
  ],
}
