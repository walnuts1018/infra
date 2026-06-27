local app = import 'app.json5';
(import '../../components/external-secret.libsonnet') {
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
