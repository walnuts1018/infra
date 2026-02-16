(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'prometheus-operator-crds',
  repoURL: 'https://prometheus-community.github.io/helm-charts',
  targetRevision: '27.0.0',
}
