(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'mackerel-api-key',
      remoteRef: {
        key: 'mackerel',
        property: 'api-key',
      },
    },
  ],
}
