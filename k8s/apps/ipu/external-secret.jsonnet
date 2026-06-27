local app = import 'app.json5';
(import '../../components/external-secret.libsonnet') {
  name: app.name,
  data: [
    {
      secretKey: 'client-id',
      remoteRef: {
        key: 'ipu-oauth2-proxy',
        property: 'client-id',
      },
    },
    {
      secretKey: 'client-secret',
      remoteRef: {
        key: 'ipu-oauth2-proxy',
        property: 'client-secret',
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
