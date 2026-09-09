{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'ClusterRole',
  metadata: {
    name: 'radar-operator',
  },
  rules: [
    {
      apiGroups: [''],
      resources: ['pods/log'],
      verbs: ['get'],
    },
    {
      apiGroups: [''],
      resources: ['pods'],
      verbs: ['delete'],
    },
    {
      apiGroups: ['apps'],
      resources: ['deployments', 'statefulsets'],
      verbs: ['patch'],
    },
  ],
}
