(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'client-id',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'ipu-client-id',
      },
    },
    {
      secretKey: 'client-secret',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'ipu-client-secret',
      },
    },
    {
      secretKey: 'session-secret',
      remoteRef: {
        key: 'ipu-oauth2-proxy',
        property: 'cookie-secret',
      },
    },
  ],
}
