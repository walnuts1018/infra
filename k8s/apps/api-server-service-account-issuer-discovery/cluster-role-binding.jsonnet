{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'ClusterRoleBinding',
  metadata: {
    name: 'api-server-service-account-issuer-discovery',
  },
  roleRef: {
    apiGroup: 'rbac.authorization.k8s.io',
    kind: 'ClusterRole',
    name: 'system:service-account-issuer-discovery',
  },
  subjects: [
    {
      kind: 'User',
      name: 'system:anonymous',
      apiGroup: 'rbac.authorization.k8s.io',
    },
  ],
}
