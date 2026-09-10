{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'Role',
  metadata: {
    name: 'argocd-agent-secret-reader-biscuit',
    namespace: 'argocd',
  },
  rules: [
    {
      apiGroups: [''],
      resources: ['secrets'],
      resourceNames: ['argocd-agent-ca', 'argocd-agent-client-tls-biscuit'],
      verbs: ['get'],
    },
    {
      apiGroups: ['authorization.k8s.io'],
      resources: ['selfsubjectrulesreviews'],
      verbs: ['create'],
    },
  ],
}
