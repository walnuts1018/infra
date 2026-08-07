local app = import 'app.json5';

(import '../../components/external-secret.libsonnet') {
  name: app.name + '-zitadel-oidc',
  namespace: app.namespace,
  type: 'secrets.pinniped.dev/oidc-client',
  template_data: {
    clientID: '{{ .client_id }}',
    clientSecret: '{{ .client_secret }}',
  },
  data: [
    {
      secretKey: 'client_id',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'pinniped-client-id',
      },
    },
    {
      secretKey: 'client_secret',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'pinniped-client-secret',
      },
    },
  ],
}
