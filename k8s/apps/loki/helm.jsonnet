local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  ociChartURL: 'ghcr.io/grafana-community/helm-charts/loki',
  targetRevision: '21.6.4',
  values: (importstr 'values.yaml'),
}
