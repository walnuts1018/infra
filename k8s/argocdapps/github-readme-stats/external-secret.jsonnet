(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
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