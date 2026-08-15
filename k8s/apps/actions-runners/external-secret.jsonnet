(import '../../components/external-secret.libsonnet') {
  use_suffix: false,
  name: 'arc-secret',
  namespace: (import 'app.json5').namespace,
  data: [
    {
      secretKey: 'github_app_id',
      remoteRef: {
        key: 'github-arc',
        property: 'github_app_id',
      },
    },
    {
      secretKey: 'github_app_installation_id',
      remoteRef: {
        key: 'github-arc',
        property: 'github_app_installation_id',
      },
    },
    {
      secretKey: 'github_app_private_key',
      remoteRef: {
        key: 'github-arc',
        property: 'github_app_private_key',
      },
    },
  ],
}
