local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  ociChartURL: 'ghcr.io/grafana-community/helm-charts/loki',
  targetRevision: '18.13.8',
  values: (importstr 'values.yaml'),
}
