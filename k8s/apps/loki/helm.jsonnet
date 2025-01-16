(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'loki',
  repoURL: 'https://grafana.github.io/helm-charts',
  targetRevision: '6.24.1',
  values: (importstr 'values.yaml'),
}
