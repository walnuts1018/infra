local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'qdrant',
  repoURL: 'https://qdrant.github.io/qdrant-helm',
  targetRevision: '1.19.0',
  values: (importstr 'values.yaml'),
}
