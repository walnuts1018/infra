local app = import 'app.json5';
(import '../../components/external-secret.libsonnet') {
  name: app.name,
  use_suffix: false,
  data: [
    {
      secretKey: 'cloudflare_api_token',
      remoteRef: {
        key: 'external-dns',
        property: 'cloudflare_api_token',
      },
    },
  ],
}
