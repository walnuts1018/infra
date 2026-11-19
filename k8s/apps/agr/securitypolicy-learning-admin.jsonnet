local app = import 'app.json5';
local oidc = import 'external-secret-oidc.jsonnet';
local adminRoute = import 'http-route-learning-admin.jsonnet';
{
  apiVersion: 'gateway.envoyproxy.io/v1alpha1',
  kind: 'SecurityPolicy',
  metadata: {
    name: app.name + '-learning-admin',
    namespace: app.namespace,
  },
  spec: {
    targetRefs: [{
      group: 'gateway.networking.k8s.io',
      kind: 'HTTPRoute',
      name: adminRoute.metadata.name,
    }],
    // 管理APIはJWTをCookieから読むため、同じセッションを復号するOIDC filterも必要。
    oidc: {
      provider: { issuer: 'https://auth.walnuts.dev' },
      clientIDRef: { name: oidc.spec.target.name },
      clientSecret: { name: oidc.spec.target.name },
      redirectURL: 'https://agr.walnuts.dev/oauth2/callback',
      logoutPath: '/logout',
      cookieNames: {
        accessToken: 'agr-access-token',
        idToken: 'agr-id-token',
        suffix: 'agr',
      },
      forwardAccessToken: false,
      scopes: [
        'openid',
        'email',
        'profile',
        'offline_access',
        'urn:zitadel:iam:org:projects:roles',
      ],
    },
    jwt: {
      providers: [{
        name: 'zitadel',
        issuer: 'https://auth.walnuts.dev',
        remoteJWKS: { uri: 'https://auth.walnuts.dev/oauth/v2/keys' },
        extractFrom: { cookies: ['agr-access-token'] },
        claimToHeaders: [{ claim: 'sub', header: 'x-authenticated-controller-id' }],
      }],
    },
    authorization: {
      defaultAction: 'Deny',
      rules: [{
        name: 'agr-user',
        action: 'Allow',
        principal: {
          jwt: {
            provider: 'zitadel',
            claims: [{
              name: 'my:zitadel:grants',
              valueType: 'StringArray',
              values: ['399549847444652339:agr-user'],
            }],
          },
        },
      }],
    },
  },
}
