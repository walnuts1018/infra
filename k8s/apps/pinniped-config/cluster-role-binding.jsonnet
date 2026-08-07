{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'ClusterRoleBinding',
  metadata: {
    name: 'pinniped-admins',
  },
  roleRef: {
    apiGroup: 'rbac.authorization.k8s.io',
    kind: 'ClusterRole',
    name: 'cluster-admin',
  },
  subjects: [
    {
      kind: 'Group',
      name: 'pinniped-admin',
      apiGroup: 'rbac.authorization.k8s.io',
    },
  ],
}
