local app = import 'app.json5';
(import '../../components/external-secret.libsonnet') {
  name: app.name + '-sso',
  namespace: app.namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'client-id',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'argo-workflows-client-id',
      },
    },
    {
      secretKey: 'client-secret',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'argo-workflows-client-secret',
      },
    },
  ],
}
