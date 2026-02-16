[
  {
    apiVersion: 'argoproj.io/v1alpha1',
    kind: 'Application',
    metadata: {
      name: (import 'app.json5').name + '-kustomize-crd',
      namespace: 'argocd',
    },
    spec: {
      project: 'default',
      destination: {
        namespace: (import 'app.json5').namespace,
        server: 'https://kubernetes.default.svc',
      },
      source: {
        path: 'client/config/crd',
        repoURL: 'https://github.com/kubernetes-csi/external-snapshotter',
        targetRevision: 'v8.3.0',
      },
      syncPolicy: {
        automated: {
          selfHeal: true,
          prune: true,
        },
      },
    },
  },
  {
    apiVersion: 'argoproj.io/v1alpha1',
    kind: 'Application',
    metadata: {
      name: (import 'app.json5').name + '-kustomize-snapshot-controller',
      namespace: 'argocd',
    },
    spec: {
      project: 'default',
      destination: {
        namespace: (import 'app.json5').namespace,
        server: 'https://kubernetes.default.svc',
      },
      source: {
        path: 'deploy/kubernetes/snapshot-controller',
        repoURL: 'https://github.com/kubernetes-csi/external-snapshotter',
        targetRevision: 'v8.3.0',
      },
      syncPolicy: {
        automated: {
          selfHeal: true,
          prune: true,
        },
      },
    },
  },
]
