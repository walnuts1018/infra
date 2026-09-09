function(app)
  local sa = (import 'client-cert-sa.libsonnet')(app);
  [
    {
      apiVersion: 'rbac.authorization.k8s.io/v1',
      kind: 'Role',
      metadata: {
        name: app.name + '-read-scylla-client-cert',
        namespace: 'databases',
      },
      rules: [
        {
          apiGroups: [''],
          resources: ['secrets'],
          resourceNames: ['scylla-cluster-local-client-ca'],
          verbs: ['get'],
        },
      ],
    },
    {
      apiVersion: 'rbac.authorization.k8s.io/v1',
      kind: 'RoleBinding',
      metadata: {
        name: app.name + '-read-scylla-client-cert',
        namespace: 'databases',
      },
      roleRef: {
        apiGroup: 'rbac.authorization.k8s.io',
        kind: 'Role',
        name: app.name + '-read-scylla-client-cert',
      },
      subjects: [
        {
          kind: 'ServiceAccount',
          name: sa.metadata.name,
          namespace: sa.metadata.namespace,
        },
      ],
    },
  ]
