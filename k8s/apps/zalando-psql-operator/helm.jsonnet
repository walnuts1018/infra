(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'postgres-operator',
  repoURL: 'https://opensource.zalando.com/postgres-operator/charts/postgres-operator',
  targetRevision: '1.14.0',
  values: (importstr 'values.yaml'),
}
