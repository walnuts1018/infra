(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'metrics-server',
  repoURL: 'https://kubernetes-sigs.github.io/metrics-server/',
  targetRevision: '3.12.2',
  values: (importstr 'values.yaml'),
}
