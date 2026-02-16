(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'client_id',
      remoteRef: {
        key: 'pomerium',
        property: 'client_id',
      },
    },
    {
      secretKey: 'client_secret',
      remoteRef: {
        key: 'pomerium',
        property: 'client_secret',
      },
    },
  ],
}
