function(app) [
  {
    name: 'OIDC_ISSUER',
    value: 'https://auth.walnuts.dev',
  },
  {
    name: 'OIDC_AUTH_URL',
    value: 'https://auth.walnuts.dev/oauth/v2/authorize',
  },
  {
    name: 'OIDC_REDIRECT_URL',
    value: 'https://' + app.name + '.walnuts.dev/auth/callback',
  },
  {
    name: 'PUBLIC_API_URL',
    value: 'https://' + app.name + '.walnuts.dev',
  },
  {
    name: 'ALLOWED_ORIGIN',
    value: 'https://' + app.name + '.walnuts.dev',
  },
  {
    name: 'GRAPHQL_QUERY_SIGNING_REQUIRED',
    value: 'true',
  },
]
