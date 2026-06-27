local app = import 'app.json5';
(import '../../components/external-secret.libsonnet') {
  name: app.name,
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
