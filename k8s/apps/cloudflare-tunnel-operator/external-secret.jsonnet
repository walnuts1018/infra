local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';
(externalSecret) {
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
