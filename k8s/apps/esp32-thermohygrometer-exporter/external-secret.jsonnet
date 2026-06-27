local app = import 'app.json5';
(import '../../components/external-secret.libsonnet') {
  name: app.name,
  data: [
    {
      secretKey: 'device_url',
      remoteRef: {
        key: 'esp32_thermohygrometer_exporter',
        property: 'device_url',
      },
    },
    {
      secretKey: 'private_key_json',
      remoteRef: {
        key: 'esp32_thermohygrometer_exporter',
        property: 'private_key_json',
      },
    },
  ],
}
