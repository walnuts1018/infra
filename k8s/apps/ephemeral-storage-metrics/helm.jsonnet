local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'k8s-ephemeral-storage-metrics',
  repoURL: 'https://jmcgrath207.github.io/k8s-ephemeral-storage-metrics/chart',
  targetRevision: '1.21.1',
  values: (importstr 'values.yaml'),
}
