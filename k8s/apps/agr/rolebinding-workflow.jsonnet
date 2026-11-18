local app = import 'app.json5';
{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'RoleBinding',
  metadata: {
    name: 'agr-workflow',
    namespace: app.namespace,
  },
  roleRef: {
    apiGroup: 'rbac.authorization.k8s.io',
    kind: 'Role',
    name: 'agr-workflow',
  },
  subjects: [{
    kind: 'ServiceAccount',
    name: 'agr-workflow',
    namespace: app.namespace,
  }],
}
