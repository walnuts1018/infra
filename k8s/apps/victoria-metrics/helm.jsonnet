(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'victoria-metrics-cluster',
  repoURL: 'https://victoriametrics.github.io/helm-charts/',
  targetRevision: '0.33.0',
  values: (importstr 'values.yaml'),
}
