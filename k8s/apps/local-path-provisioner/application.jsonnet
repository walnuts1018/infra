{
  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'Application',
  metadata: {
    name: (import 'app.json5').name + '-external',
    namespace: 'argocd',
  },
  spec: {
    project: 'default',
    destination: {
      namespace: (import 'app.json5').namespace,
      server: 'https://kubernetes.default.svc',
    },
    source: {
      path: 'deploy',
      repoURL: 'https://github.com/rancher/local-path-provisioner',
      targetRevision: 'v0.0.32',
      kustomize: {
        patches: [
          {
            patch: '$patch: delete\napiVersion: v1\nkind: Namespace\nmetadata:\n  name: local-path-storage',
          },
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
