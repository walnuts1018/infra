local app = import '../pinniped/app.json5';
local certificate = import 'certificate.jsonnet';

{
  apiVersion: 'config.supervisor.pinniped.dev/v1alpha1',
  kind: 'FederationDomain',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    annotations: {
      'argocd.argoproj.io/sync-options': 'SkipDryRunOnMissingResource=true',
    },
  },
  spec: {
    issuer: 'https://kurumi-pinniped.local.walnuts.dev',
    tls: {
      secretName: certificate.spec.secretName,
    },
    identityProviders: [
      {
        displayName: 'ZITADEL',
        objectRef: {
          apiGroup: 'idp.supervisor.pinniped.dev',
          kind: 'OIDCIdentityProvider',
          name: 'zitadel',
        },
      },
    ],
  },
}
