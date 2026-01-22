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
      path: 'config/gateway-api',
      repoURL: 'https://github.com/pomerium/ingress-controller',
      targetRevision: 'v0.32.0',
      kustomize: {
        patches: [
          {
            target: {
              kind: 'Namespace',
              name: 'pomerium',
            },
            patch: |||
              - op: "delete"
            |||,
          },
          {
            target: {
              kind: 'Deployment',
              name: 'pomerium',
              namespace: 'pomerium',
            },
            patch: |||
              - op: "replace"
                path: "/spec/template/spec/containers/0/resources"
                value: {"requests": {"cpu": "10m", "memory": "32Mi"}, "limits": {"cpu": "1", "memory": "1Gi"}}
            |||,
          },
          {
            target: {
              kind: 'Service',
              name: 'pomerium-metrics',
              namespace: 'pomerium',
            },
            patch: |||
              - op: "add"
                path: "/metadata/labels/role"
                value: metrics
            |||,
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
