(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'prometheus-smartctl-exporter',
  repoURL: 'https://prometheus-community.github.io/helm-charts',
  targetRevision: '0.15.3',
  values: (importstr 'values.yaml'),
}
