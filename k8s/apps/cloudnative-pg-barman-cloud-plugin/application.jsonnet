{
  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'Application',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    project: 'default',
    destination: {
      namespace: (import 'app.json5').namespace,
      server: 'https://kubernetes.default.svc',
    },
    source: {
      path: 'k8s/apps/cloudnative-pg-barman-cloud-plugin/_kustomize',
      repoURL: 'https://github.com/walnuts1018/infra',
      targetRevision: 'main',
      kustomize: {
        patches: [
        ],
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
