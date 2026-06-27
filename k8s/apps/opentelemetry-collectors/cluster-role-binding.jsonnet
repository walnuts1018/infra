local app = import 'app.json5';
{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'ClusterRoleBinding',
  metadata: {
    name: app.name,
  },
  subjects: [
    {
      kind: 'ServiceAccount',
      name: (import 'sa.jsonnet').metadata.name,
      namespace: app.namespace,
    },
  ],
  roleRef: {
    kind: 'ClusterRole',
    name: (import 'cluster-role.jsonnet').metadata.name,
    apiGroup: 'rbac.authorization.k8s.io',
  },
}
