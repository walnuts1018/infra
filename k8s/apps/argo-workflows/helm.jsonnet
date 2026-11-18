local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'argo-workflows',
  repoURL: 'https://argoproj.github.io/argo-helm',
  targetRevision: '2.0.18',
  values: (importstr 'values.yaml'),
  spec+: {
    syncPolicy+: {
      syncOptions+: ['CreateNamespace=true'],
    },
  },
}
