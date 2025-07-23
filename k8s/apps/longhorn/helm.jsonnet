(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'longhorn',
  repoURL: 'https://charts.longhorn.io',
  targetRevision: '1.9.1',
  values: (importstr 'values.yaml'),
}
