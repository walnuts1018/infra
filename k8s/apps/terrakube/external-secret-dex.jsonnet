(import '../../components/external-secret.libsonnet') {
  name: 'terrakube-api-secrets-overlay',
  namespace: (import '../app.json5').namespace,
  data: [
    {
      secretKey: 'clientSecret',
      remoteRef: {
        key: 'terrakube',
        property: 'client_secret',
      },
    },
  ],
  template_data: {
    'config.yaml': (importstr '_config/dex-config.yaml'),
  },
}
