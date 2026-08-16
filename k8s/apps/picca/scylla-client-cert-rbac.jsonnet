local sa = import 'scylla-client-cert-sa.jsonnet';
[
  {
    apiVersion: 'rbac.authorization.k8s.io/v1',
    kind: 'Role',
    metadata: {
      name: 'picca-read-scylla-client-cert',
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
      name: 'picca-read-scylla-client-cert',
      namespace: 'databases',
    },
    roleRef: {
      apiGroup: 'rbac.authorization.k8s.io',
      kind: 'Role',
      name: 'picca-read-scylla-client-cert',
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
