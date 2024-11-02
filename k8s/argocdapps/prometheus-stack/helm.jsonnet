(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'kube-prometheus-stack',
  repoURL: 'https://prometheus-community.github.io/helm-charts',
  targetRevision: '65.5.1',
  values: (importstr 'values.yaml'),
}
