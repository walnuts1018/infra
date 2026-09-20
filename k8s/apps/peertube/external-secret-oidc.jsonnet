local app = import 'app.json5';

(import '../../components/external-secret.libsonnet') {
  name: app.name + '-oidc',
  namespace: app.namespace,
  data: [
    {
      secretKey: 'client_id',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'peertube-client-id',
      },
    },
    {
      secretKey: 'client_secret',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'peertube-client-secret',
      },
    },
  ],
  template_data: {
    'client-id': '{{ .client_id }}',
    'client-secret': '{{ .client_secret }}',
  },
}
