(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'prometheus-blackbox-exporter',
  repoURL: 'https://prometheus-community.github.io/helm-charts',
  targetRevision: '11.0.1',
  values: (importstr 'values.yaml'),
}
