(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'tenant',
  repoURL: 'https://operator.min.io/',
  targetRevision: '7.1.1',
  values: (importstr 'values.yaml'),
}
