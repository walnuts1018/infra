local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
local values = importstr 'values.yaml';
(helm) {
  name: app.name,
  namespace: app.namespace,

  chart: 'k8s-ephemeral-storage-metrics',
  repoURL: 'https://jmcgrath207.github.io/k8s-ephemeral-storage-metrics/chart',
  targetRevision: '1.19.2',
  values: (values),
}
