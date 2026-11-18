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
      secretKey: 'AGR_LEARNING_ADMIN_GATEWAY_TOKEN',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'agr-learning-admin-gateway-token',
      },
    },
  ],
  template_data: {
    AGR_LEARNING_ADMIN_IDENTITIES: '{{ .AGR_LEARNING_ADMIN_IDENTITIES }}',
    AGR_LEARNING_ADMIN_GATEWAY_TOKEN: '{{ .AGR_LEARNING_ADMIN_GATEWAY_TOKEN }}',
    credential: '{{ .AGR_LEARNING_ADMIN_GATEWAY_TOKEN }}',
  },
}
