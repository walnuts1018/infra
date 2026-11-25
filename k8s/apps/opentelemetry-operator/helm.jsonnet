local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,

  chart: 'opentelemetry-operator',
  repoURL: 'https://open-telemetry.github.io/opentelemetry-helm-charts',
  targetRevision: '0.129.2',
  values: (importstr 'values.yaml'),
}
