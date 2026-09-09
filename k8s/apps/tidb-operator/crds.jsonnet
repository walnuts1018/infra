local app = import 'app.json5';
{
  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'Application',
  metadata: {
    name: app.name + '-crds',
    namespace: 'argocd',
    finalizers: [
      'resources-finalizer.argocd.argoproj.io',
    ],
  },
  spec: {
    project: 'default',
    destination: {
      server: 'https://kubernetes.default.svc',
    },
    source: {
      repoURL: 'https://github.com/pingcap/tidb-operator',
      targetRevision: 'v1.6.6',
      path: 'manifests/crd/v1',
      directory: {
        recurse: true,
      },
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
