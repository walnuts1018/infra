(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'zitadel',
  repoURL: 'https://charts.zitadel.com',
  targetRevision: '8.13.1',
  values: (importstr 'values.yaml'),
}
