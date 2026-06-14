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
      clientId: 'TODO_REPLACE_WITH_LONGHORN_CLIENT_ID',
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
    authorization: {
      defaultAction: 'Deny',
      rules: [
        {
          action: 'Allow',
          principal: {
            jwt: {
              claims: [
                {
                  name: 'urn:zitadel:iam:org:project:356681781363081691:roles',
                  valueType: 'StringArray',
                  value: 'longhorn-admin',
                },
              ],
            },
          },
        },
      ],
    },
  },
}
