local sa = import '../minio-biscuit-backup-trigger/sa.jsonnet';
local app = import 'app.json5';
{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'RoleBinding',
  metadata: {
    name: app.name + '-kurumi-rolebinding',
    namespace: app.namespace,
  },
  subjects: [
    {
      kind: 'User',
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
