local app = import 'app.json5';
(import '../../components/external-secret.libsonnet') {
  name: app.name + '-rclone',
  namespace: app.namespace,
  data: [
    {
      secretKey: 'B2_APPLICATION_KEY',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'b2-application-key',
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
