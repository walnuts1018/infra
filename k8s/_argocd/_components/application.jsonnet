(import '../../common/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'argo-cd',
  repoURL: 'https://argoproj.github.io/argo-helm',
  targetRevision: '7.6.12',
  values: (importstr 'values.yaml'),
}
