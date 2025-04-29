(import '../helm.libsonnet') {
  upstream:: error 'upstream is required',
  allowed_groups:: error 'allowed_groups is required',
  domain:: error 'domain is required',
  secret_name:: error 'secret_name is required',
  redis_name:: error 'redis_name is required',
  valuesObjectOverride:: {},

  name: error 'name is required',
  namespace: error 'namespace is required',
  chart: 'oauth2-proxy',
  repoURL: 'https://oauth2-proxy.github.io/manifests',
  targetRevision: '7.12.11',
  values: '',
  valuesObject: std.mergePatch((import 'values.libsonnet') {
    upstream: $.upstream,
    allowed_groups: $.allowed_groups,
    domain: $.domain,
    secret_name: $.secret_name,
    redis_name: $.redis_name,
  }, $.valuesObjectOverride),
}
