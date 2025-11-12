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
    {
      secretKey: 'b2_crypted_password',
      remoteRef: {
        key: 'rclone',
        property: 'b2_crypt_password',
      },
    },
    {
      secretKey: 'b2_crypted_salt',
      remoteRef: {
        key: 'rclone',
        property: 'b2_crypt_salt',
      },
    },
  ],
  template_data: {
    'rclone.conf': (importstr './_config/rclone.conf.tmpl'),
  },
}
