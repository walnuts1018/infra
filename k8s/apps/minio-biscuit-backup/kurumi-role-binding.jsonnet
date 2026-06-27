local sa = import '../minio-biscuit-backup-trigger/sa.jsonnet';
local app = import 'app.json5';
local kurumiRole = import 'kurumi-role.jsonnet';
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
      local sa = (sa),
      name: 'https://192.168.0.17:16443#system:serviceaccount:' + sa.metadata.namespace + ':' + sa.metadata.name,
      apiGroup: 'rbac.authorization.k8s.io',
    },
  ],
  roleRef: {
    apiGroup: 'rbac.authorization.k8s.io',
    kind: 'Role',
    name: kurumiRole.metadata.name,
  },
}
