local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';
(externalSecret) {
  name: app.name + '-rclone',
  namespace: app.namespace,
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
