local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
local values = importstr 'values.yaml';
(helm) {
  name: app.name,
  namespace: app.namespace,
  ociChartURL: 'ghcr.io/grafana/helm-charts/pyroscope',
  targetRevision: '2.0.1',
  values: (values),
}
