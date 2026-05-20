{
  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'Application',
  metadata: {
    name: (import 'app.json5').name + '-kustomize',
    namespace: 'argocd',
  },
  spec: {
    project: 'default',
    destination: {
      namespace: (import 'app.json5').namespace,
      server: 'https://kubernetes.default.svc',
    },
    source: {
      path: 'k8s/apps/rabbitmq-operator/_kustomize',
      repoURL: 'https://github.com/walnuts1018/infra',
      targetRevision: 'main',
    },
    syncPolicy: {
      automated: {
        selfHeal: true,
        prune: true,
      },
      syncOptions: [
        'ServerSideApply=true',
        'FailOnSharedResource=true',
      ],
    },
  },
}
