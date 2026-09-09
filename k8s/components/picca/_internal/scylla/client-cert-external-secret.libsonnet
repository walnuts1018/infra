function(app)
  local store = (import 'client-cert-store.libsonnet')(app);
  {
    apiVersion: 'external-secrets.io/v1',
    kind: 'ExternalSecret',
    metadata: {
      name: 'scylla-cluster-local-client-ca',
      namespace: app.namespace,
    },
    spec: {
      secretStoreRef: {
        name: store.metadata.name,
        kind: 'SecretStore',
      },
      refreshInterval: '1h',
      target: {
        name: 'scylla-cluster-local-client-ca',
      },
      dataFrom: [
        {
          extract: {
            key: 'scylla-cluster-local-client-ca',
          },
        },
      ],
    },
  }
