{
  apiVersion: 'external-secrets.io/v1beta1',
  kind: 'ExternalSecret',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  spec: {
    secretStoreRef: {
      name: 'onepassword',
      kind: 'ClusterSecretStore',
    },
    refreshInterval: '1m',
    target: {
      name: (import 'app.json5').name,
    },
    data: [
      {
        secretKey: 'cloudflared-token',
        remoteRef: {
          key: 'cloudflare',
          property: 'k8s-tunnel-token',
        },
      },
    ],
  },
}
