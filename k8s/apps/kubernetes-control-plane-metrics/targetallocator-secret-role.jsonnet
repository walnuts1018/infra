local app = import 'app.json5';
{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'Role',
  metadata: {
    name: app.name + '-targetallocator-secret-reader',
    namespace: app.namespace,
  },
  rules: [
    {
      apiGroups: [''],
      resources: ['secrets'],
      verbs: ['get', 'list', 'watch'],
    },
  ],
}
