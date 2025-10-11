{
  name:: error 'name is required',
  namespace:: error 'namespace is required',
  redirect_url:: error 'redirect_url is required',
  logout_path:: null,
  client_id:: error 'client_id is required',
  client_secret_secret_name:: error 'client_secret_secret_name is required',
  targetRef:: error 'targetRef is required',

  apiVersion: 'gateway.envoyproxy.io/v1alpha1',
  kind: 'SecurityPolicy',
  metadata: {
    name: $.name,
    namespace: $.namespace,
  },
  spec: {
    targetRef: $.targetRef,
    oidc: {
      provider: {
        issuer: 'https://auth.walnuts.dev',
      },
      clientID: $.client_id,
      clientSecret: {
        name: $.client_secret_secret_name,
      },
      redirectURL: $.redirect_url,
      logoutPath: $.logout_path,
    },
  },
}
