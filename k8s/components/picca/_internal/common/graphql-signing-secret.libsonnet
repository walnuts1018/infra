function(app, useSuffix=true)
  local graphqlQuerySigningPublicKeys = 'v1-2026-09=cFst-Ky0SkPjPSYfFaqcIzsqvDQ_ZxBmeE8Cm0-l4yE';
  local secretName = app.name + '-graphql-query-signing-public-keys';
  {
    apiVersion: 'v1',
    kind: 'Secret',
    metadata: {
      name: secretName,
      namespace: app.namespace,
    },
    stringData: {
      GRAPHQL_QUERY_SIGNING_PUBLIC_KEYS: graphqlQuerySigningPublicKeys,
    },
    // Deployment定義から参照するSecret名を共通化しつつ、manifestへは出力しない。
    spec:: {
      target: { name: secretName },
    },
  }
