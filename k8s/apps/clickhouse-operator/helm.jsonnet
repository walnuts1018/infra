local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  ociChartURL: 'ghcr.io/clickhouse/clickhouse-operator-helm',
  targetRevision: '0.0.6',
  values: (importstr 'values.yaml'),
}
