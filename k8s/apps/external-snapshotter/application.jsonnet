local app = import 'app.json5';
[
  {
    apiVersion: 'argoproj.io/v1alpha1',
    kind: 'Application',
    metadata: {
      name: app.name + '-kustomize-crd',
      namespace: 'argocd',
    },
    spec: {
      project: 'default',
      destination: {
        namespace: app.namespace,
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
      name: app.name + '-kustomize-snapshot-controller',
      namespace: 'argocd',
    },
    spec: {
      project: 'default',
      destination: {
        namespace: app.namespace,
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
