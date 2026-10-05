local app = import 'app.json5';
local externalSecret = import 'external-secret.jsonnet';
{
  apiVersion: 'gateway.envoyproxy.io/v1alpha1',
  kind: 'SecurityPolicy',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    annotations: {
      'argocd.argoproj.io/sync-wave': '-1',
    },
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
      redirectURL: 'https://ipu.walnuts.dev/auth/callback',
      logoutPath: '/logout',
      cookieNames: {
        accessToken: 'ipu-access-token',
        idToken: 'ipu-id-token',
      },
      disableTokenEncryption: false,
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
      providers: [
        {
          name: 'zitadel',
          issuer: 'https://auth.walnuts.dev',
          audiences: ['385244306622906793'],
          remoteJWKS: {
            uri: 'https://auth.walnuts.dev/oauth/v2/keys',
          },
          extractFrom: {
            cookies: ['ipu-access-token'],
          },
        },
      ],
    },
    authorization: {
      defaultAction: 'Deny',
      rules: [
        {
          name: 'viewer',
          action: 'Allow',
          principal: {
            jwt: {
              provider: 'zitadel',
              claims: [
                {
                  name: 'my:zitadel:grants',
                  valueType: 'StringArray',
                  values: ['385244306220253385:viewer'],
                },
              ],
            },
          },
        },
      ],
    },
  },
}
