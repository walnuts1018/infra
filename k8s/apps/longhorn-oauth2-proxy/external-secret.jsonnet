(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name + '-secret',
  data: [
    {
      secretKey: 'client-id',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'longhorn-client-id',
      },
    },
    {
      secretKey: 'client-secret',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'longhorn-client-secret',
      },
    },
  ],
}
