(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'client-id',
      remoteRef: {
        key: 'ipu-oauth2-proxy/client-id',
      },
    },
    {
      secretKey: 'client-secret',
      remoteRef: {
        key: 'ipu-oauth2-proxy/client-secret',
      },
    },
    {
      secretKey: 'session-secret',
      remoteRef: {
        key: 'ipu-oauth2-proxy/cookie-secret',
      },
    },
  ],
}
