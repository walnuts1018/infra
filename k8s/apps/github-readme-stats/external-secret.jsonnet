local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';
(externalSecret) {
  name: app.name,
  data: [
    {
      secretKey: 'github-token',
      remoteRef: {
        key: 'github_token',
        property: 'github-readme-stats',
      },
    },
  ],
}
