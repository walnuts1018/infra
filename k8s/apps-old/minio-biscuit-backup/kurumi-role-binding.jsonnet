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
      local sa = (import '../minio-biscuit-backup-trigger/sa.jsonnet'),
      name: 'https://192.168.0.17:16443#system:serviceaccount:' + sa.metadata.namespace + ':' + sa.metadata.name,
      apiGroup: 'rbac.authorization.k8s.io',
    },
  ],
  roleRef: {
    apiGroup: 'rbac.authorization.k8s.io',
    kind: 'Role',
    name: (import 'kurumi-role.jsonnet').metadata.name,
  },
}
