(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'kube-prometheus-stack',
  repoURL: 'https://prometheus-community.github.io/helm-charts',
  targetRevision: '67.3.1',
  values: (importstr 'values.yaml'),
}
