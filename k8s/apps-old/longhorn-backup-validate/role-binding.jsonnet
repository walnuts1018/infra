{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'RoleBinding',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
  },
  subjects: [
    {
      kind: 'ServiceAccount',
      name: (import 'sa.jsonnet').metadata.name,
      namespace: (import 'app.json5').namespace,
    },
  ],
  roleRef: {
    kind: 'Role',
    name: (import 'role.jsonnet').metadata.name,
    apiGroup: 'rbac.authorization.k8s.io',
  },
}
