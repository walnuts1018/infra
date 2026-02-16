(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'admin_token',
      remoteRef: {
        key: 'mpeg-dash-encoder',
        property: 'admin_token',
      },
    },
    {
      secretKey: 'jwt_sign_secret',
      remoteRef: {
        key: 'mpeg-dash-encoder',
        property: 'jwt_sign_secret',
      },
    },
    {
      secretKey: 'minio_secret_key',
      remoteRef: {
        key: 'mpeg-dash-encoder',
        property: 'minio_secret_key',
      },
    },
  ],
}
