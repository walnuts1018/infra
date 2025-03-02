(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'cilium',
  repoURL: 'https://helm.cilium.io/',
  targetRevision: '1.17.1',
  values: (importstr 'values.yaml'),
}
