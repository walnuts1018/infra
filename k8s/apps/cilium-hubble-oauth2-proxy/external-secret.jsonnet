local app = import 'app.json5';
(import '../../components/external-secret.libsonnet') {
  name: app.name + '-secret',
  data: [
    {
      secretKey: 'client-id',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'hubble-client-id',
      },
    },
    {
      secretKey: 'client-secret',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'hubble-client-secret',
      },
    },
  ],
}
