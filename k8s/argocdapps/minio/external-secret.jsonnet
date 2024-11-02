(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'client-secret',
      remoteRef: {
        key: 'minio',
        property: 'client-secret',
      },
    },
    {
      secretKey: 'admin-secret-key',
      remoteRef: {
        key: 'minio',
        property: 'admin-secret-key',
      },
    },
  ],
}
