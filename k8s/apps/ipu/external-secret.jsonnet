(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  metadata+: {
    annotations: {
      'argocd.argoproj.io/sync-wave': '-2',
    },
  },
  data: [
    {
      secretKey: 'client-id',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'ipu-client-id',
      },
    },
    {
      secretKey: 'client-secret',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'ipu-client-secret',
      },
    },
  ],
}
