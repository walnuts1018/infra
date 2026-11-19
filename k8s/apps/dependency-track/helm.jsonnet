local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  ociChartURL: 'ghcr.io/dependencytrack/helm-charts/dependency-track',
  targetRevision: '2.9.0',
  values: (importstr 'values.yaml'),
}
