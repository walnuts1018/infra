local app = import 'app.json5';
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
        name: app.name + '-oidc',
      },
      clientSecret: {
        name: app.name + '-oidc',
      },
      scopes: [
        'openid',
        'email',
        'profile',
        'offline_access',
        'urn:zitadel:iam:org:projects:roles',
      ],
      forwardAccessToken: true,
      redirectURL: 'https://peertube.walnuts.dev/oauth2/callback',
      logoutPath: '/oauth2/logout',
    },
  },
}
