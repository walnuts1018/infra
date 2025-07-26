(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'opentelemetry-operator',
  repoURL: 'https://open-telemetry.github.io/opentelemetry-helm-charts',
  targetRevision: '0.92.1',
  values: (importstr 'values.yaml'),
}
