(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name + '-secret',
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
