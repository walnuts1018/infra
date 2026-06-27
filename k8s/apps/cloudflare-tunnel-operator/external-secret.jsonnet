local app = import 'app.json5';
(import '../../components/external-secret.libsonnet') {
  use_suffix: false,
  name: app.name,
  namespace: app.namespace,
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
