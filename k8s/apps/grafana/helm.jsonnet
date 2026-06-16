(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'grafana',
  repoURL: 'https://grafana-community.github.io/helm-charts',
  targetRevision: '12.4.6',
  values: (importstr 'values.yaml'),
}
