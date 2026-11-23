local app = import 'app.json5';
{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'Role',
  metadata: {
    name: 'agr-workflow-dashboard',
    namespace: app.namespace,
  },
  rules: [
    {
      apiGroups: ['metrics.k8s.io'],
      resources: ['pods'],
      verbs: ['list'],
    },
  ],
}
