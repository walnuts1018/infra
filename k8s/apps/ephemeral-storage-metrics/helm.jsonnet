(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'k8s-ephemeral-storage-metrics',
  repoURL: 'https://jmcgrath207.github.io/k8s-ephemeral-storage-metrics/chart',
  targetRevision: '1.18.1',
  values: (importstr 'values.yaml'),
}
