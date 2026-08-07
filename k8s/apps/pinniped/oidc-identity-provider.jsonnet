local app = import 'app.json5';
local clientSecret = import 'external-secret.jsonnet';

{
  apiVersion: 'idp.supervisor.pinniped.dev/v1alpha1',
  kind: 'OIDCIdentityProvider',
  metadata: {
    name: 'zitadel',
    namespace: app.namespace,
  },
  spec: {
    issuer: 'https://auth.walnuts.dev',
    authorizationConfig: {
      additionalScopes: ['email', 'offline_access', 'profile'],
      allowPasswordGrant: false,
    },
    claims: {
      username: 'email',
      groups: 'urn:zitadel:iam:org:project:roles',
    },
    client: {
      secretName: clientSecret.spec.target.name,
    },
  },
}
