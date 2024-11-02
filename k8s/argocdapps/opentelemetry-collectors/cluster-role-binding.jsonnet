{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'ClusterRoleBinding',
  metadata: {
    name: (import 'app.json5').name,
  },
  subjects: [
    {
      kind: 'ServiceAccount',
      name: (import 'sa.jsonnet').metadata.name,
      namespace: (import 'app.json5').namespace,
    },
  ],
  roleRef: {
    kind: 'ClusterRole',
    name: (import 'cluster-role.jsonnet').metadata.name,
    apiGroup: 'rbac.authorization.k8s.io',
  },
}
