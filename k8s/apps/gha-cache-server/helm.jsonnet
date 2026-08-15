local app = import 'app.json5';

(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  ociChartURL: 'ghcr.io/falcondev-oss/charts/github-actions-cache-server',
  targetRevision: '1.1.3',
  values: (importstr 'values.yaml'),
}
