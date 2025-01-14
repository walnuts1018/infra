(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'minio',
  repoURL: 'https://charts.min.io/',
  targetRevision: '5.4.0',
  values: (importstr 'values.yaml'),
}
