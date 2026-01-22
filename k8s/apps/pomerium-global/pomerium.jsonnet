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
    secrets: (import 'app.json5').namespace + '/' + 'bootstrap',
    identityProvider: {
      provider: 'oidc',
      scopes: [
        'openid',
        'email',
        'profile',
      ],
      secret: (import 'app.json5').namespace + '/' + (import 'external-secret.jsonnet').spec.target.name,
      url: 'https://auth.walnuts.dev',
    },
  },
}
