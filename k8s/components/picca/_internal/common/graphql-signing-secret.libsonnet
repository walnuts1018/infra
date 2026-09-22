function(app, useSuffix=true)
  (import '../../../external-secret.libsonnet') {
    name: app.name + '-graphql-query-signing-public-keys',
    namespace: app.namespace,
    use_suffix: useSuffix,
    data: [
      {
        secretKey: 'graphql_query_signing_public_keys',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: app.name + '-graphql-query-signing-public-keys',
        },
      },
    ],
    template_data: {
      GRAPHQL_QUERY_SIGNING_PUBLIC_KEYS: '{{ .graphql_query_signing_public_keys }}',
    },
  }
