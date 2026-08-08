local kubeoidcProxyApp = import '../kube-oidc-proxy/app.json5';
local app = import 'app.json5';

(import '../../components/external-secret.libsonnet') {
  name: app.name + '-oidc',
  use_suffix: false,
  data: [
    {
      secretKey: 'OIDC_CLIENT_ID',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'headlamp-client-id',
      },
    },
    {
      secretKey: 'OIDC_CLIENT_SECRET',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'headlamp-client-secret',
      },
    },
  ],
  template_data: {
    OIDC_CLIENT_ID: '{{ .OIDC_CLIENT_ID }}',
    OIDC_CLIENT_SECRET: '{{ .OIDC_CLIENT_SECRET }}',
    OIDC_ISSUER_URL: 'https://auth.walnuts.dev',
    OIDC_SCOPES: 'openid,email,profile,urn:zitadel:iam:org:project:id:' + kubeoidcProxyApp.params.oidcIssuerAudience + ':aud',
    OIDC_CALLBACK_URL: 'https://headlamp.walnuts.dev/oidc-callback',
    OIDC_USE_PKCE: 'true',
    OIDC_USE_ACCESS_TOKEN: 'true',
  },
}
