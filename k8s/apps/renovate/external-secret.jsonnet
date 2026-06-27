local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';
(externalSecret) {
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
