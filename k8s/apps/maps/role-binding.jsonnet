local app = import 'app.json5';
local sa = import 'updater-sa.jsonnet';
{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'RoleBinding',
  metadata: {
    name: app.name + '-rollout-restart',
    namespace: app.namespace,
  },
  roleRef: {
    apiGroup: 'rbac.authorization.k8s.io',
    kind: 'Role',
    name: (import 'role.jsonnet').metadata.name,
  },
  subjects: [
    {
      kind: 'ServiceAccount',
      name: sa.metadata.name,
      namespace: sa.metadata.namespace,
    },
  ],
}
