local app = (import 'app.json5');
local httproute = (import './httproute.jsonnet');
local secret = (import './external-secret.jsonnet');

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
        name: httproute.metadata.name,
      },
    ],
    oidc: {
      provider: {
        issuer: 'https://auth.walnuts.dev',
      },
      clientID: '377362576486433474',
      clientSecret: {
        name: secret.spec.target.name,
      },
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
                  name: 'urn:zitadel:iam:org:project:377362576134111938:roles',
                  valueType: 'StringArray',
                  values: ['longhorn-admin'],
                },
              ],
            },
          },
        },
      ],
    },
  },
}
