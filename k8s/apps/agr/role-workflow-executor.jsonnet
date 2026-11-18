local app = import 'app.json5';
{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'Role',
  metadata: {
    name: 'agr-workflow-executor',
    namespace: app.namespace,
  },
  rules: [{
    apiGroups: ['argoproj.io'],
    resources: ['workflowtaskresults'],
    verbs: ['create', 'patch'],
  }],
}
