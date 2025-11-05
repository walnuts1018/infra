{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'Role',
  metadata: {
    name: (import 'app.json5').name + '-kurumi-role',
    namespace: (import 'app.json5').namespace,
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
