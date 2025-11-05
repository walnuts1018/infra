{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'RoleBinding',
  metadata: {
    name: (import 'app.json5').name + '-kurumi-rolebinding',
    namespace: (import 'app.json5').namespace,
  },
  subjects: [
    {
      kind: 'User',
      name: 'system:serviceaccount:minio:minio-biscuit-backup-trigger',
      apiGroup: 'rbac.authorization.k8s.io',
    },
  ],
  roleRef: {
    apiGroup: 'rbac.authorization.k8s.io',
    kind: 'Role',
    name: (import 'kurumi-role.jsonnet').metadata.name,
  },
}
