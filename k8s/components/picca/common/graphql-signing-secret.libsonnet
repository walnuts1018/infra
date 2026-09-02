function(app, useSuffix=true)
  (import '../../external-secret.libsonnet') {
    name: app.name + '-graphql-signing-secret',
    namespace: app.namespace,
    use_suffix: useSuffix,
    data: [
      {
        secretKey: 'graphql_query_signing_secret',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: app.name + '-graphql-query-signing-secret',
        },
      },
    ],
    template_data: {
      GRAPHQL_QUERY_SIGNING_SECRET: '{{ .graphql_query_signing_secret }}',
      PICCA_GRAPHQL_QUERY_SIGNING_SECRET: '{{ .graphql_query_signing_secret }}',
    },
  }
