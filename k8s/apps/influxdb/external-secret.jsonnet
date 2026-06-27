local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';
(externalSecret) {
  name: app.name,
  use_suffix: false,
  data: [
    {
      secretKey: 'admin-password',
      remoteRef: {
        key: 'influxdb',
        property: 'admin-password',
      },
    },
    {
      secretKey: 'admin-token',
      remoteRef: {
        key: 'influxdb',
        property: 'admin-token',
      },
    },
  ],
}
