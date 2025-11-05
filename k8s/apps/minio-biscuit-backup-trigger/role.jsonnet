{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'Role',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
  },
  rules: [
    {
      apiGroups: [
        'batch',
      ],
      resources: [
        'jobs',
        'cronjobs',
      ],
      verbs: [
        'get',
        'list',
        'watch',
      ],
    },
  ],
}
