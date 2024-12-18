(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'GITHUB_COM_TOKEN',
      remoteRef: {
        key: 'renovate',
        property: 'github_token',
      },
    },
  ],
}
