local app = import 'app.json5';
(import '../../components/external-secret.libsonnet') {
  name: app.name + '-secret',
  data: [
    {
      secretKey: 'client-secret',
      remoteRef: {
        key: 'longhorn-oauth2-proxy',
        property: 'client_secret',
      },
    },
  ],
}
