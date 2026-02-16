(import '../../components/external-secret.libsonnet') {
  name: 'cloudflare-api-token',
  data: [
    {
      secretKey: 'api-token',
      remoteRef: {
        key: 'cloudflare',
        property: 'zone-api-token',
      },
    },
  ],
}
