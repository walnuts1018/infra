local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  ociChartURL: 'ghcr.io/grafana/helm-charts/pyroscope',
  targetRevision: '2.0.1',
  values: (importstr 'values.yaml'),
}
