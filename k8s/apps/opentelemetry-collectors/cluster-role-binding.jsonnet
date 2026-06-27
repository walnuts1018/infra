local app = import 'app.json5';
local clusterRole = import 'cluster-role.jsonnet';
local sa = import 'sa.jsonnet';
{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'ClusterRoleBinding',
  metadata: {
    name: app.name,
  },
  subjects: [
    {
      kind: 'ServiceAccount',
      name: sa.metadata.name,
      namespace: app.namespace,
    },
  ],
  roleRef: {
    kind: 'ClusterRole',
    name: clusterRole.metadata.name,
    apiGroup: 'rbac.authorization.k8s.io',
  },
}
