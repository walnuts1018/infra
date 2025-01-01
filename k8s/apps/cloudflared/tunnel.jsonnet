{
  apiVersion: 'cf-tunnel-operator.walnuts.dev/v1beta1',
  kind: 'CloudflareTunnel',
  metadata: {
    name: 'cloudflare-tunnel',
    namespace: (import 'app.json5').namespace,
    labels: {
      app: 'cloudflare-tunnel',
    },
  },
  spec: {
    replicas: 3,
    default: true,
  },
}
