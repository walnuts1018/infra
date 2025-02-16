(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'descheduler',
  repoURL: 'https://kubernetes-sigs.github.io/descheduler/',
  targetRevision: '0.32.2',
  values: (importstr 'values.yaml'),
}
