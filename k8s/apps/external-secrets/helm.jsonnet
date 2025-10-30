(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'external-secrets',
  repoURL: 'https://charts.external-secrets.io',
  targetRevision: '0.20.4',
  values: (importstr 'values.yaml'),
}
