(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'external-secrets',
  repoURL: 'https://charts.external-secrets.io',
  targetRevision: '0.12.1',
  values: '',
}
