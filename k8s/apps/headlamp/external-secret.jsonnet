local app = import 'app.json5';

(import '../../components/external-secret.libsonnet') {
  name: app.name + '-oidc',
  use_suffix: false,
  data: [
    {
      secretKey: 'OIDC_CLIENT_ID',
      remoteRef: {
        key: 'headlamp',
        property: 'client_id',
      },
    },
    {
      secretKey: 'OIDC_CLIENT_SECRET',
      remoteRef: {
        key: 'headlamp',
        property: 'client_secret',
      },
    },
  ],
  template_data: {
    OIDC_CLIENT_ID: '{{ .OIDC_CLIENT_ID }}',
    OIDC_CLIENT_SECRET: '{{ .OIDC_CLIENT_SECRET }}',
    OIDC_ISSUER_URL: 'https://auth.walnuts.dev',
    OIDC_SCOPES: 'openid,email,profile',
    OIDC_CALLBACK_URL: 'https://headlamp.walnuts.dev/oidc-callback',
    OIDC_USE_PKCE: 'true',
  },
}
