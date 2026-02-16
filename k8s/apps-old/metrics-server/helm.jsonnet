(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'metrics-server',
  repoURL: 'https://kubernetes-sigs.github.io/metrics-server/',
  targetRevision: '3.13.0',
  values: (importstr 'values.yaml'),
}
