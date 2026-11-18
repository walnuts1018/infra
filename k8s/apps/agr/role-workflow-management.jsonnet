local app = import 'app.json5';
{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'Role',
  metadata: {
    name: 'agr-workflow-management',
    namespace: app.namespace,
  },
  rules: [
    {
      apiGroups: ['argoproj.io'],
      resources: ['workflows'],
      verbs: ['get', 'list', 'watch', 'create', 'patch', 'delete'],
    },
  ],
}
