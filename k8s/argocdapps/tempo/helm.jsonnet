(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'tempo',
  repoURL: 'https://grafana.github.io/helm-charts',
  targetRevision: '1.11.0',
  values: (importstr 'values.yaml'),
}
