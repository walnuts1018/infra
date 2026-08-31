local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  ociChartURL: 'ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller',
  targetRevision: '0.14.2',
  values: (importstr 'values.yaml'),
}
