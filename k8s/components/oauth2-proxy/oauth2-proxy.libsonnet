{
  app:: {
    name:: error 'name is required',
    namespace:: error 'namespace is required',
  },
  domain:: error 'domain is required',
  upstream:: error 'upstream is required',
  oidc:: {
    secret:: {
      onepassword_item_name:: error 'onepassword_item_name is required',
    },
    allowed_group:: error 'allowed_group is required',
  },

  secret_name:: $.app.name + '-oauth2-proxy',

  redis:: (import './redis.libsonnet') {
    name: $.app.name + '-oauth2-proxy-redis',
    secret_name: $.secret_name,
  },

  apiVersion: 'v1',
  kind: 'List',
  items: [
    (import './external-secret.libsonnet') {
      name: $.secret_name,
      onepassword_item_name: $.oidc.secret.onepassword_item_name,
    },
    (import './helm.libsonnet') {
      name: $.app.name + '-oauth2-proxy',
      namespace: $.app.namespace,

      upstream: $.upstream,
      allowed_groups: $.oidc.allowed_group,
      domain: $.domain,
      secret_name: $.secret_name,
      redis_name: $.redis.name,
    },
    $.redis.items[0],
    $.redis.items[1],
  ],
}
