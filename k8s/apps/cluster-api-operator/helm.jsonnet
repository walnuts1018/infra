(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'cluster-api-operator',
  repoURL: 'https://kubernetes-sigs.github.io/cluster-api-operator',
  targetRevision: '0.24.0',
  valuesObject: {},
}
