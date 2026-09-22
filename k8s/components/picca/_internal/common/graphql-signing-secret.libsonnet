function(app, useSuffix=true)
  local graphqlQuerySigningPublicKeys = 'v1-2026-09=cFst-Ky0SkPjPSYfFaqcIzsqvDQ_ZxBmeE8Cm0-l4yE';
  (import '../../../external-secret.libsonnet') {
    name: app.name + '-graphql-query-signing-public-keys',
    namespace: app.namespace,
    use_suffix: useSuffix,
    data: [],
    template_data: {
      GRAPHQL_QUERY_SIGNING_PUBLIC_KEYS: graphqlQuerySigningPublicKeys,
    },
  }
