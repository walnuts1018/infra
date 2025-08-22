(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'cloudnative-pg',
  repoURL: 'https://cloudnative-pg.github.io/charts',
  targetRevision: '0.26.0',
  values: (importstr 'values.yaml'),
}
