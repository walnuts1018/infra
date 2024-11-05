(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'cf-api-token',
      remoteRef: {
        key: 'cloudflare',
        property: 'apitoken',
      },
    },
  ],
}
