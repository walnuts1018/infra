local app = import 'app.json5';
{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'Role',
  metadata: {
    name: 'agr-workflow',
    namespace: app.namespace,
  },
  rules: [{
    apiGroups: ['batch'],
    resources: ['jobs'],
    verbs: ['create', 'get', 'patch', 'delete'],
  }],
}
