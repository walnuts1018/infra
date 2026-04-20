(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  ociChartURL: 'ghcr.io/grafana-community/helm-charts/loki',
  targetRevision: '6.55.0',
  values: (importstr 'values.yaml'),
}
