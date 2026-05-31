(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'grafana',
  repoURL: 'https://grafana.github.io/helm-charts',
  targetRevision: '10.5.15',
  values: (importstr 'values.yaml'),
}
