(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'zitadel',
  repoURL: 'https://charts.zitadel.com',
  targetRevision: '9.0.0',
  values: (importstr 'values.yaml'),
}
