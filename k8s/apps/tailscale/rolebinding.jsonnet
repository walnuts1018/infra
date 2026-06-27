local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'RoleBinding',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (labels)(app.name),
  },
  subjects: [
    {
      kind: 'ServiceAccount',
      name: (import 'sa.jsonnet').metadata.name,
    },
  ],
  roleRef: {
    kind: 'Role',
    name: (import 'role.jsonnet').metadata.name,
    apiGroup: 'rbac.authorization.k8s.io',
  },
}
