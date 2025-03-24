(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'AUTH_SECRET',
      remoteRef: {
        key: 'maple',
        property: 'AUTH_SECRET',
      },
    },
    {
      secretKey: 'AUTH_ZITADEL_SECRET',
      remoteRef: {
        key: 'maple',
        property: 'AUTH_ZITADEL_SECRET',
      },
    },
  ],
}
