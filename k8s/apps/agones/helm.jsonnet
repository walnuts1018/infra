(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'agones',
  repoURL: 'https://agones.dev/chart/stable',
  targetRevision: '1.52.2',
  values: (importstr 'values.yaml'),
}
