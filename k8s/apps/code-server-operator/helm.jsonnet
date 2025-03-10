(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'code-server-operator',
  repoURL: 'https://walnuts1018.github.io/code-server-operator/',
  targetRevision: '0.5.13',
  values: (importstr 'values.yaml'),
}
