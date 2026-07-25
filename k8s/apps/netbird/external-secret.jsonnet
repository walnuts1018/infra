local app = import 'app.json5';
(import '../../components/external-secret.libsonnet') {
  name: app.name + '-config',
  namespace: app.namespace,
  data: [
    {
      secretKey: 'NB_SETUP_KEY',
      remoteRef: {
        key: 'netbird',
        property: 'setup-key',
      },
    },
    {
      secretKey: 'auth_secret',
      remoteRef: {
        key: 'netbird',
        property: 'auth-secret',
      },
    },
    {
      secretKey: 'store_encryption_key',
      remoteRef: {
        key: 'netbird',
        property: 'store-encryption-key',
      },
    },
    {
      secretKey: 'postgres_password',
      remoteRef: {
        key: 'postgres_passwords',
        property: 'netbird',
      },
    },
  ],
  template_data: {
    'config.yaml': (importstr './_config/config.yaml'),
    NB_SETUP_KEY: '{{ .NB_SETUP_KEY }}',
  },
}
