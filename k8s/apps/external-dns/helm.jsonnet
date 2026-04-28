(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'external-dns',
  repoURL: 'https://kubernetes-sigs.github.io/external-dns/',
  targetRevision: '1.20.0',
  values: (importstr 'values.yaml'),
}
