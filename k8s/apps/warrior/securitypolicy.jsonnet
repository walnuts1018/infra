local app = import 'app.json5';
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
        name: (import './httproute.jsonnet').metadata.name,
      },
    ],
    oidc: {
      provider: {
        issuer: 'https://auth.walnuts.dev',
      },
      clientIDRef: {
        name: (import './external-secret.jsonnet').spec.target.name,
      },
      clientSecret: {
        name: (import './external-secret.jsonnet').spec.target.name,
      },
      scopes: [
        'openid',
        'email',
        'profile',
        'offline_access',
        'urn:zitadel:iam:org:projects:roles',
      ],
      forwardAccessToken: true,
      logoutPath: '/oauth2/logout',
    },
    jwt: {
      providers: [
        {
          name: 'zitadel',
          issuer: 'https://auth.walnuts.dev',
          remoteJWKS: {
            uri: 'https://auth.walnuts.dev/oauth/v2/keys',
          },
        },
      ],
    },
    authorization: {
      defaultAction: 'Deny',
      rules: [
        {
          action: 'Allow',
          principal: {
            jwt: {
              provider: 'zitadel',
              claims: [
                {
                  name: 'my:zitadel:grants',
                  valueType: 'StringArray',
                  values: ['TODO_PROJECT_ID:warrior-user'],
                },
              ],
            },
          },
        },
      ],
    },
  },
}
