local app = import 'app.json5';
{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'RoleBinding',
  metadata: {
    name: 'agr-workflow-dashboard',
    namespace: app.namespace,
  },
  roleRef: {
    apiGroup: 'rbac.authorization.k8s.io',
    kind: 'Role',
    name: 'agr-workflow-dashboard',
  },
  subjects: [{
    kind: 'ServiceAccount',
    name: 'agr-app-service',
    namespace: app.namespace,
  }],
}
