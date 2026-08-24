local app = import 'app.json5';

(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  ociChartURL: 'ghcr.io/walnuts1018/charts/smart-hibernatable-actions-runner-controller',
  targetRevision: '0.0.4',
  values: (importstr 'values.yaml'),
}
