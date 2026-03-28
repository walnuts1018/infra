(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'external-secrets',
  repoURL: 'https://charts.external-secrets.io',
  targetRevision: '2.2.0',
  values: (importstr 'values.yaml'),
}
