local role = import 'role.jsonnet';
local sa = import 'sa.jsonnet';
{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'RoleBinding',
  metadata: {
    name: (import 'app.json5').name,
    namespace: role.metadata.namespace,
  },
  subjects: [
    {
      kind: 'ServiceAccount',
      name: sa.metadata.name,
      namespace: sa.metadata.namespace,
    },
  ],
  roleRef: {
    kind: 'Role',
    name: role.metadata.name,
    apiGroup: 'rbac.authorization.k8s.io',
  },
}
