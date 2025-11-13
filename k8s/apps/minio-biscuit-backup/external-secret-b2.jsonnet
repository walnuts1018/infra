(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name + '-rclone',
  namespace: (import 'app.json5').namespace,
  data: [
    {
      secretKey: 'B2_APPLICATION_KEY',
      remoteRef: {
        key: 'b2',
        property: 'application_key',
      },
    },
    {
      secretKey: 'B2_ENCRYPTED_PASSWORD',
      remoteRef: {
        key: 'rclone',
        property: 'b2_crypt_password',
      },
    },
    {
      secretKey: 'B2_ENCRYPTED_SALT',
      remoteRef: {
        key: 'rclone',
        property: 'b2_crypt_salt',
      },
    },
  ],
}
