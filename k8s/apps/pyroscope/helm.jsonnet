(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  ociChartURL: 'ghcr.io/grafana/helm-charts/pyroscope',
  targetRevision: '2.0.1',
  values: (importstr 'values.yaml'),
}
