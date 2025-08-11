(import '../../components/external-secret.libsonnet') {
  use_suffix: false,
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  data: [
    {
      secretKey: 'cloudflareAPIToken',
      remoteRef: {
        key: 'cloudflare',
        property: 'cloudflare-tunnel-operator',
      },
    },
  ],
}
