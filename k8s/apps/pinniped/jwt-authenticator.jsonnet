{
  apiVersion: 'authentication.concierge.pinniped.dev/v1alpha1',
  kind: 'JWTAuthenticator',
  metadata: {
    name: 'pinniped-supervisor',
  },
  spec: {
    issuer: (import 'federation-domain.jsonnet').spec.issuer,
    audience: 'kurumi',
    claims: {
      username: 'username',
      groups: 'groups',
    },
  },
}
