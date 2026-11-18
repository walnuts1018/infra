local app = import 'app.json5';
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
