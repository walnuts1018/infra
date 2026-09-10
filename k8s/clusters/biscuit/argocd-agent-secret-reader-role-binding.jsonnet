{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'RoleBinding',
  metadata: {
    name: 'argocd-agent-secret-reader-biscuit',
    namespace: 'argocd',
  },
  roleRef: {
    apiGroup: 'rbac.authorization.k8s.io',
    kind: 'Role',
    name: 'argocd-agent-secret-reader-biscuit',
  },
  subjects: [
    {
      kind: 'ServiceAccount',
      name: 'argocd-agent-secret-reader-biscuit',
      namespace: 'argocd',
    },
  ],
}
