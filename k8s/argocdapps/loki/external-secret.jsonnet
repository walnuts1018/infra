(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
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
  ],
}
