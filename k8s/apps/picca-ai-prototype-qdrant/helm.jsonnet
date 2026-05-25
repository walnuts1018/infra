(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'qdrant',
  repoURL: 'https://qdrant.github.io/qdrant-helm',
  targetRevision: '1.18.0',
  values: (importstr 'values.yaml'),
}
