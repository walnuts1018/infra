local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';
(externalSecret) {
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
