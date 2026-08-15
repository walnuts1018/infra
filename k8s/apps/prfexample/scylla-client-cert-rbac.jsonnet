local sa = import 'scylla-client-cert-sa.jsonnet';
// databases namespaceにある scylla-cluster-local-client-ca Secretを、
// External Secrets Operatorのkubernetes providerでprfexample namespaceへ複製するためのRBAC。
// Role/RoleBindingはSecretの所在するnamespace(databases)側に作る必要があるため、
// このファイルはprfexample appの一部でありながらmetadata.namespaceをdatabasesに向けている。
[
  {
    apiVersion: 'rbac.authorization.k8s.io/v1',
    kind: 'Role',
    metadata: {
      name: 'prfexample-read-scylla-client-cert',
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
      name: 'prfexample-read-scylla-client-cert',
      namespace: 'databases',
    },
    roleRef: {
      apiGroup: 'rbac.authorization.k8s.io',
      kind: 'Role',
      name: 'prfexample-read-scylla-client-cert',
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
