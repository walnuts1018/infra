{
  secret_name:: error 'secret_name is required',
  upstream:: error 'upstream is required',
  allowed_groups:: error 'allowed_groups is required',
  domain:: error 'domain is required',
  redis_name:: error 'redis_name is required',

  config: {
    existingSecret: $.secret_name,
    configFile: 'email_domains = [ "*" ]\nupstreams = [ "%s" ]\npass_access_token = true\nuser_id_claim = "sub"\noidc_groups_claim="my:zitadel:grants"\nallowed_groups = ["%s"]' % [$.upstream, $.allowed_groups],
  },
  extraArgs: {
    provider: 'oidc',
    'redirect-url': 'https://%s/oauth2/callback' % $.domain,
    'oidc-issuer-url': 'https://auth.walnuts.dev',
    'skip-provider-button': true,
    'code-challenge-method': 'S256',
  },
  ingress: {
    enabled: true,
    className: 'cilium',
    path: '/',
    pathType: 'Prefix',
    hosts: [
      $.domain,
    ],
  },
  sessionStorage: {
    type: 'redis',
    redis: {
      existingSecret: $.secret_name,
      passwordKey: 'redis-password',
      clientType: 'sentinel',
      sentinel: {
        existingSecret: $.secret_name,
        passwordKey: 'redis-password',
        masterName: 'mymaster',
        connectionUrls: 'redis://%s:6379,redis://%s:26379' % [$.redis_name, $.redis_name + '-sentinel'],
      },
    },
  },
  metrics: {
    enabled: true,
  },
  resources: {
    limits: {
      cpu: '100m',
      memory: '128Mi',
    },
    requests: {
      cpu: '1m',
      memory: '5Mi',
    },
  },
  tolerations: [
    {
      key: 'node.walnuts.dev/low-performance',
      operator: 'Exists',
    },
    {
      key: 'node.walnuts.dev/untrusted',
      operator: 'Exists',
    },
  ],
}
