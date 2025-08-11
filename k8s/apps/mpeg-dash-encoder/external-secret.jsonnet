(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'admin_token',
      remoteRef: {
        key: 'mpeg-dash-encoder/admin_token',
      },
    },
    {
      secretKey: 'jwt_sign_secret',
      remoteRef: {
        key: 'mpeg-dash-encoder/jwt_sign_secret',
      },
    },
    {
      secretKey: 'minio_secret_key',
      remoteRef: {
        key: 'mpeg-dash-encoder/minio_secret_key',
      },
    },
  ],
}
