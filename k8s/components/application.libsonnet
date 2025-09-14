{
  name:: error 'name is required',
  namespace:: error 'namespace is required',
  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'Application',
  metadata: {
    name: $.name,
    namespace: 'argocd',
  },
  spec: {
    project: 'default',
    destination: {
      namespace: $.namespace,
      server: 'https://kubernetes.default.svc',
    },
    source: {
      path: 'k8s/apps/' + $.name,
      repoURL: 'https://github.com/walnuts1018/infra',
      targetRevision: 'main',
      directory: {
        jsonnet: {
          tlas: [
            {
              name: '',
              value: '',
            },
          ],
        },
      },
    },
    syncPolicy: {
      automated: {
        selfHeal: true,
        prune: true,
      },
    },
  },
}
