(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'agones',
  repoURL: 'https://agones.dev/chart/stable',
  targetRevision: '1.51.0',
  values: (importstr 'values.yaml'),
}
