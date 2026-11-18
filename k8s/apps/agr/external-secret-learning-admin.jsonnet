local app = import 'app.json5';
(import '../../components/external-secret.libsonnet') {
  name: app.name + '-learning-admin-credential',
  namespace: app.namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'AGR_LEARNING_ADMIN_IDENTITIES',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'agr-learning-admin-identities',
      },
    },
    {
      secretKey: 'admin_gateway_token',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'agr-learning-admin-gateway-token',
      },
    },
    {
      secretKey: 'AGR_LEARNING_ADMIN_GATEWAY_TOKEN',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'agr-learning-admin-gateway-token',
      },
    },
  ],
  template_data: {
    credential: '{{ .admin_gateway_token }}',
  },
}
