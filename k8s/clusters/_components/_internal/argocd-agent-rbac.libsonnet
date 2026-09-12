// Argo CD AgentがClusterSecretStore経由でclient証明書を読むためのRBAC一式(cluster毎に1組)。
{
  serviceAccount(clusterName):: {
    apiVersion: 'v1',
    kind: 'ServiceAccount',
    metadata: {
      name: 'argocd-agent-secret-reader-' + clusterName,
      namespace: 'argocd',
    },
  },
  role(clusterName):: {
    apiVersion: 'rbac.authorization.k8s.io/v1',
    kind: 'Role',
    metadata: {
      name: 'argocd-agent-secret-reader-' + clusterName,
      namespace: 'argocd',
    },
    rules: [
      {
        apiGroups: [''],
        resources: ['secrets'],
        resourceNames: ['argocd-agent-ca', 'argocd-agent-client-tls-' + clusterName],
        verbs: ['get'],
      },
      {
        apiGroups: ['authorization.k8s.io'],
        resources: ['selfsubjectrulesreviews'],
        verbs: ['create'],
      },
    ],
  },
  roleBinding(clusterName):: {
    apiVersion: 'rbac.authorization.k8s.io/v1',
    kind: 'RoleBinding',
    metadata: {
      name: 'argocd-agent-secret-reader-' + clusterName,
      namespace: 'argocd',
    },
    roleRef: {
      apiGroup: 'rbac.authorization.k8s.io',
      kind: 'Role',
      name: 'argocd-agent-secret-reader-' + clusterName,
    },
    subjects: [
      {
        kind: 'ServiceAccount',
        name: 'argocd-agent-secret-reader-' + clusterName,
        namespace: 'argocd',
      },
    ],
  },
}
