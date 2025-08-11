(import '../../components/external-secret.libsonnet') {
  name: 'cloudflare-api-token',
  data: [
    {
      secretKey: 'api-token',
      remoteRef: {
        key: 'cloudflare/zone-api-token',
      },
    },
  ],
}
