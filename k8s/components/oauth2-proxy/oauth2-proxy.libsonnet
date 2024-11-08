// {
//   app:: {
//     name:: error 'name is required',
//     namespace:: error 'namespace is required',
//   },
//   domain:: error 'domain is required',
//   upstream:: error 'upstream is required',
//   oidc:: {
//     secret:: {
//       onepassword_item_name:: error 'onepassword_item_name is required',
//     },
//     allowed_group:: error 'allowed_group is required',
//   },
//   valuesObject:: {},
// }

function(config, valuesObject={})
  local secret_name = config.app.name + '-oauth2-proxy' + '-' + std.md5(std.toString(config.oidc.secret))[0:6];
  local redis = (import './redis.libsonnet') {
    name: config.app.name + '-oauth2-proxy-redis',
    secret_name: secret_name,
  };

  [
    (import './external-secret.libsonnet') {
      name: secret_name,
      onepassword_item_name: config.oidc.secret.onepassword_item_name,
    },
    (import './helm.libsonnet') {
      name: config.app.name + '-oauth2-proxy',
      namespace: config.app.namespace,

      upstream: config.upstream,
      allowed_groups: config.oidc.allowed_group,
      domain: config.domain,
      secret_name: secret_name,
      redis_name: redis.name,

      valuesObjectOverride: valuesObject,
    },
    redis.items[0],
    redis.items[1],
  ]
