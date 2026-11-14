local app = import 'app.json5';
{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'Role',
  metadata: {
    name: app.name + '-learning-deploy-verify',
    namespace: app.namespace,
  },
  rules: [{
    apiGroups: [''],
    resources: ['pods'],
    verbs: ['list'],
  }],
}
