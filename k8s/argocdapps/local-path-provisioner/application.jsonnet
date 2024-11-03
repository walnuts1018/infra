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
    sources: [
      {
        repoURL: 'https://github.com/walnuts1018/infra/',
        targetRevision: 'main',
        ref: 'patch',
      },
      {
        path: 'deploy',
        repoURL: 'https://github.com/rancher/local-path-provisioner',
        targetRevision: 'v0.0.30',
        kustomize: {
          patches: [
            {
              path: '$patch/k8s/argocdapps/local-path-provisioner/namespace.yaml',
            },
          ],
        },
      },
    ],
    syncPolicy: {
      automated: {
        selfHeal: true,
        prune: true,
      },
    },
  },
}
