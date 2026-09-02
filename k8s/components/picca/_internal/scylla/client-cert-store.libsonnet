function(app)
  local sa = (import 'client-cert-sa.libsonnet')(app);
  {
    apiVersion: 'external-secrets.io/v1',
    kind: 'SecretStore',
    metadata: {
      name: 'scylla-client-cert',
      namespace: app.namespace,
    },
    spec: {
      provider: {
        kubernetes: {
          remoteNamespace: 'databases',
          server: {
            url: 'https://kubernetes.default.svc',
            caProvider: {
              type: 'ConfigMap',
              name: 'kube-root-ca.crt',
              key: 'ca.crt',
            },
          },
          auth: {
            serviceAccount: {
              name: sa.metadata.name,
              namespace: sa.metadata.namespace,
            },
          },
        },
      },
    },
  }
