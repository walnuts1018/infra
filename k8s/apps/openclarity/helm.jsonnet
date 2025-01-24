(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  ociChartURL: 'ghcr.io/openclarity/charts/openclarity',
  targetRevision: '1.1.2',
  values: (importstr 'values.yaml'),
}
