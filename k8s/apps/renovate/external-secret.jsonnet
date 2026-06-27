local app = import 'app.json5';
(import '../../components/external-secret.libsonnet') {
  name: app.name,
  data: [
    {
      secretKey: 'github-app-id',
      remoteRef: {
        key: 'renovate',
        property: 'github_app_id',
      },
    },
    {
      secretKey: 'github-app-installation-id',
      remoteRef: {
        key: 'renovate',
        property: 'github_app_installation_id',
      },
    },
    {
      secretKey: 'github-app-private-key',
      remoteRef: {
        key: 'renovate',
        property: 'github_app_private_key',
      },
    },
  ],
}
