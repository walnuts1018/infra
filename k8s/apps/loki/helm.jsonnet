(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'loki',
  repoURL: 'https://grafana.github.io/helm-charts',
  targetRevision: '6.28.0',
  values: (importstr 'values.yaml'),
}
