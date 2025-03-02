(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  use_suffix: false,
  data: [
    {
      secretKey: 'accessKeyId',
      remoteRef: {
        key: 'loki',
        property: 'minio-access-key',
      },
    },
    {
      secretKey: 'secretAccessKey',
      remoteRef: {
        key: 'loki',
        property: 'minio-secret-key',
      },
    },
    {
      secretKey: 'redispassword',
      remoteRef: {
        key: 'redis',
        property: 'password',
      },
    },
  ],
}
