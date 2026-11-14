local app = import 'app.json5';
(import '../../components/external-secret.libsonnet') {
  name: app.name + '-gateway-credential',
  namespace: app.namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'gateway_token',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'agr-gateway-token',
      },
    },
  ],
  template_data: {
    credential: '{{ .gateway_token }}',
  },
}
