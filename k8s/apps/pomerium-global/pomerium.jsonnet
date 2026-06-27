local app = import 'app.json5';
// https://www.pomerium.com/docs/internals/configuration
{
  apiVersion: 'ingress.pomerium.io/v1',
  kind: 'Pomerium',
  metadata: {
    name: 'global',
  },
  spec: {
    authenticate: {
      url: 'https://pomerium.walnuts.dev',
    },
    secrets: app.namespace + '/' + 'bootstrap',
    identityProvider: {
      provider: 'oidc',
      scopes: [
        'openid',
        'email',
        'profile',
      ],
      secret: app.namespace + '/' + (import 'external-secret.jsonnet').spec.target.name,
      url: 'https://auth.walnuts.dev',
    },
  },
}
