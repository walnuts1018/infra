{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'ClusterRole',
  metadata: {
    name: 'otel-default-collector',
  },
  rules: [
    {
      apiGroups: [
        '',
      ],
      resources: [
        'namespaces',
        'pods',
      ],
      verbs: [
        'list',
        'watch',
      ],
    },
  ],
}
