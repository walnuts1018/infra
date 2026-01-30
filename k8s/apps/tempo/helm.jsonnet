(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'tempo-distributed',
  repoURL: 'https://grafana.github.io/helm-charts',
  targetRevision: '1.61.3',
  values: (importstr 'values.yaml'),
}
