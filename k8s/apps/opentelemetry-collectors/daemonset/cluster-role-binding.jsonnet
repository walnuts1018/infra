local clusterRole = import 'cluster-role.jsonnet';
local serviceAccount = import 'sa.jsonnet';
{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'ClusterRoleBinding',
  metadata: {
    name: clusterRole.metadata.name,
  },
  subjects: [
    {
      kind: 'ServiceAccount',
      name: serviceAccount.metadata.name,
      namespace: (import '../app.json5').namespace,
    },
  ],
  roleRef: {
    kind: 'ClusterRole',
    name: clusterRole.metadata.name,
    apiGroup: 'rbac.authorization.k8s.io',
  },
}
