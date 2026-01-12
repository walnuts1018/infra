(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'tempo-distributed',
  repoURL: 'https://grafana.github.io/helm-charts',
  targetRevision: '1.60.0',
  values: (importstr 'values.yaml'),
}
