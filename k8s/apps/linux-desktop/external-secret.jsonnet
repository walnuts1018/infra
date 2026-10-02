local app = import 'app.json5';
(import '../../components/external-secret.libsonnet') {
  name: app.name + '-oidc-gateway',
  namespace: app.namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'client-id',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: app.name + '-client-id',
      },
    },
    {
      secretKey: 'client-secret',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: app.name + '-client-secret',
      },
    },
  ],
}
