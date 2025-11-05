(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name + '-rclone',
  namespace: (import 'app.json5').namespace,
  data: [
    {
      secretKey: 'b2_application_key',
      remoteRef: {
        key: 'b2',
        property: 'application_key',
      },
    },
  ],
  template_data: {
    'rclone.conf': (importstr './_config/rclone.conf.tmpl'),
  },
}
