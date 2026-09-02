local app = import 'app.json5';
local externalSecret = import 'external-secret-oidc-filter.jsonnet';

{
  apiVersion: 'gateway.envoyproxy.io/v1alpha1',
  kind: 'SecurityPolicy',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    targetRefs: [
      {
        group: 'gateway.networking.k8s.io',
        kind: 'HTTPRoute',
        name: app.name,
      },
    ],
    oidc: {
      provider: {
        issuer: 'https://auth.walnuts.dev',
      },
      clientIDRef: {
        name: externalSecret.spec.target.name,
      },
      clientSecret: {
        name: externalSecret.spec.target.name,
      },
      scopes: [
        'openid',
        'email',
        'profile',
      ],
      redirectURL: 'https://picca-dev.walnuts.dev/oauth2/callback',
      logoutPath: '/oauth2/logout',
    },
  },
}
