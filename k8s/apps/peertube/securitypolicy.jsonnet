local app = import 'app.json5';
local oidcSecret = import 'external-secret-oidc.jsonnet';
{
  apiVersion: 'gateway.envoyproxy.io/v1alpha1',
  kind: 'SecurityPolicy',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    targetRefs: [{
      group: 'gateway.networking.k8s.io',
      kind: 'HTTPRoute',
      name: app.name,
    }],
    oidc: {
      provider: {
        issuer: 'https://auth.walnuts.dev',
      },
      clientIDRef: {
        name: oidcSecret.spec.target.name,
      },
      clientSecret: {
        name: oidcSecret.spec.target.name,
      },
      scopes: [
        'openid',
        'offline_access',
      ],
      redirectURL: 'https://peertube.walnuts.dev/oauth2/callback',
      logoutPath: '/oauth2/logout',
    },
  },
}
