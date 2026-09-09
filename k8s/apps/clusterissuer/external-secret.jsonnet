(import '../../components/external-secret.libsonnet') {
  name: 'cloudflare-api-token',
  data: [
    {
      secretKey: 'api-token',
      remoteRef: {
        key: 'cert-manager',
        property: 'cloudflare_api_token',
      },
    },
  ],
}
