local app = import 'app.json5';

(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  ociChartURL: 'ghcr.io/konoe-akitoshi/charts/shumoku',
  targetRevision: '0.2.0',
  values: (importstr 'values.yaml'),
}
