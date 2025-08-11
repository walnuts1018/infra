(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  use_suffix: false,
  data: [
    {
      secretKey: 'admin-password',
      remoteRef: {
        key: 'influxdb/admin-password',
      },
    },
    {
      secretKey: 'admin-token',
      remoteRef: {
        key: 'influxdb/admin-token',
      },
    },
  ],
}
