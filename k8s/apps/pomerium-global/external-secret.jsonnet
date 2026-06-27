local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';
(externalSecret) {
  name: app.name,
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
