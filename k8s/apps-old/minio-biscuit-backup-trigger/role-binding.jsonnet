{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'RoleBinding',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'role.jsonnet').metadata.namespace,
  },
  subjects: [
    {
      kind: 'ServiceAccount',
      name: (import 'sa.jsonnet').metadata.name,
      namespace: (import 'sa.jsonnet').metadata.namespace,
    },
  ],
  roleRef: {
    kind: 'Role',
    name: (import 'role.jsonnet').metadata.name,
    apiGroup: 'rbac.authorization.k8s.io',
  },
}
