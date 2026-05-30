(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'device_url',
      remoteRef: {
        key: 'esp32_thermohygrometer_exporter',
        property: 'device_url',
      },
    },
    {
      secretKey: 'oidc_client_secret',
      remoteRef: {
        key: 'esp32_thermohygrometer_exporter',
        property: 'oidc_client_secret',
      },
    },
  ],
}
