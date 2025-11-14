(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'prometheus-operator-crds',
  repoURL: 'https://prometheus-community.github.io/helm-charts',
  targetRevision: '79.5.0',
}
