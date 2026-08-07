local app = import 'app.json5';

(import '../../components/external-secret.libsonnet') {
  name: app.name + '-oidc',
  data: [
    {
      secretKey: 'client-id',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'shumoku-client-id',
      },
    },
    {
      secretKey: 'client-secret',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'shumoku-client-secret',
      },
    },
  ],
}
