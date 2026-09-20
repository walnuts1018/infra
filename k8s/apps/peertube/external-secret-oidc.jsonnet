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
    {
      secretKey: 'role_claim',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'peertube-role-claim',
      },
    },
    {
      secretKey: 'role_claim_property',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'peertube-role-claim-property',
      },
    },
  ],
  template_data: {
    'client-id': '{{ .client_id }}',
    'client-secret': '{{ .client_secret }}',
    'role-claim': '{{ .role_claim }}',
    'role-claim-property': '{{ .role_claim_property }}',
  },
}
