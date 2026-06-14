(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'kube-state-metrics',
  repoURL: 'https://prometheus-community.github.io/helm-charts',
  targetRevision: '7.5.1',
  values: (importstr 'values.yaml'),
}
