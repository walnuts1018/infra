function(app, postgresMaxConns='2')
  (import 'observability.libsonnet')(app)
  + (import 'storage.libsonnet')(app)
  + (import 'database.libsonnet')(app, postgresMaxConns)
  + (import 'oidc.libsonnet')(app)
  + (import 'search-ai.libsonnet')(app)
  + [
    {
      name: 'GRAPHQL_QUERY_SIGNING_PUBLIC_KEYS',
      value: 'v1-2026-09=cFst-Ky0SkPjPSYfFaqcIzsqvDQ_ZxBmeE8Cm0-l4yE',
    },
  ]
