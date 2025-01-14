(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  ociChartURL: 'ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller',
  targetRevision: '0.10.1',
  values: (importstr 'values.yaml'),
}
