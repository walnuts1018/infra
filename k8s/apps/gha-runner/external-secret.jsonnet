(import '../../components/external-secret.libsonnet') {
  use_suffix: false,
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  data: [
    {
      secretKey: 'github_app_id',
      remoteRef: {
        key: 'github',
        property: 'github_app_id',
      },
    },
    {
      secretKey: 'github_app_installation_id',
      remoteRef: {
        key: 'github',
        property: 'github_app_installation_id',
      },
    },
    {
      secretKey: 'github_app_private_key',
      remoteRef: {
        key: 'github',
        property: 'github_app_private_key',
      },
    },
  ],
}
