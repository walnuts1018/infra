std.mergePatch((import '../../components/external-secret.libsonnet') {
  name: 'cloudflare-origin-cert',
  namespace: (import 'app.json5').namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'tls.crt',
      remoteRef: {
        key: 'cloudflare-origin-cert/tls.crt',
      },
    },
    {
      secretKey: 'tls.key',
      remoteRef: {
        key: 'cloudflare-origin-cert/tls.key',
      },
    },
  ],
}, {
  spec: {
    target: {
      template: {
        type: 'kubernetes.io/tls',
      },
    },
  },
})
