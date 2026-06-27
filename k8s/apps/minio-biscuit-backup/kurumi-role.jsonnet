local app = import 'app.json5';
{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'Role',
  metadata: {
    name: app.name + '-kurumi-role',
    namespace: app.namespace,
  },
  rules: [
    {
      apiGroups: [
        'batch',
      ],
      resources: [
        'cronjobs',
      ],
      verbs: [
        'get',
        'list',
        'watch',
      ],
    },
    {
      apiGroups: [
        'batch',
      ],
      resources: [
        'jobs',
      ],
      verbs: [
        'get',
        'list',
        'watch',
        'create',
      ],
    },
  ],
}
