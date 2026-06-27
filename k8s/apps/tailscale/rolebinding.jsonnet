local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local role = import 'role.jsonnet';
local sa = import 'sa.jsonnet';
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
      name: sa.metadata.name,
    },
  ],
  roleRef: {
    kind: 'Role',
    name: role.metadata.name,
    apiGroup: 'rbac.authorization.k8s.io',
  },
}
