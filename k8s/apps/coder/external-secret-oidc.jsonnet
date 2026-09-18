local app = import 'app.json5';

(import '../../components/external-secret.libsonnet') {
  name: 'coder-oidc',
  namespace: app.namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'client-id',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'coder-client-id',
      },
    },
    {
      secretKey: 'client-secret',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'coder-client-secret',
      },
    },
  ],
}
