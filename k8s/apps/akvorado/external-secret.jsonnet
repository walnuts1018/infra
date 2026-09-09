(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name + '-secret',
  data: [
    {
      secretKey: 'client-id',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'akvorado-client-id',
      },
    },
    {
      secretKey: 'client-secret',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'akvorado-client-secret',
      },
    },
  ],
}
