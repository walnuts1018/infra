(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'github-token',
      remoteRef: {
        key: 'renovate',
        property: 'github_token',
      },
    },
  ],
}
