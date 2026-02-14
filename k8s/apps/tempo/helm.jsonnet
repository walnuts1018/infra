(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'tempo-distributed',
  repoURL: 'https://grafana-community.github.io/helm-charts',
  targetRevision: '2.1.2',
  values: (importstr 'values.yaml'),
}
