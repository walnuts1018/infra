(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  use_suffix:: false,
  data: [
    {
      secretKey: 'db_password',
      remoteRef: {
        key: 'postgres_passwords',
        property: 'gha_cache_server',
      },
    },
  ],
}
