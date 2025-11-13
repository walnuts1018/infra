std.mergePatch((import '../../components/external-secret.libsonnet') {
  name: 'cilium-cluster-mesh',
  namespace: (import 'app.json5').namespace,
  data: [
    {
      secretKey: 'ca.crt',
      remoteRef: {
        key: 'cilium-cluster-mesh',
        property: 'ca.crt',
      },
    },
    {
      secretKey: 'tls.crt',
      remoteRef: {
        key: 'cilium-cluster-mesh',
        property: 'tls.crt',
      },
    },
    {
      secretKey: 'tls.key',
      remoteRef: {
        key: 'cilium-cluster-mesh',
        property: 'tls.key',
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
