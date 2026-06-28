local app = import 'app.json5';
{
  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'Application',
  metadata: {
    name: app.name + '-kustomize',
    namespace: 'argocd',
  },
  spec: {
    project: 'default',
    destination: {
      namespace: app.namespace,
      server: 'https://kubernetes.default.svc',
    },
    source: {
      path: 'k8s/apps/cloudnative-pg-barman-cloud-plugin/_kustomize',
      repoURL: 'https://github.com/walnuts1018/infra',
      targetRevision: 'main',
      // kustomize: {
      //   patches: [],
      // },
    },
    syncPolicy: {
      automated: {
        selfHeal: true,
        prune: true,
      },
    },
  },
}
