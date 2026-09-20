local app = import 'app.json5';
{
  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'Application',
  metadata: {
    name: app.name,
    namespace: 'argocd',
    finalizers: [
      'resources-finalizer.argocd.argoproj.io',
    ],
  },
  spec: {
    project: 'default',
    destination: {
      namespace: app.namespace,
      server: 'https://kubernetes.default.svc',
    },
    source: {
      path: 'k8s/overlays/production',
      repoURL: 'https://github.com/walnuts1018/beast',
      targetRevision: 'main',
    },
    syncPolicy: {
      automated: {
        selfHeal: true,
        prune: true,
      },
    },
  },
}
