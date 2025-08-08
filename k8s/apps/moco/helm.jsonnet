(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'moco',
  repoURL: 'https://cybozu-go.github.io/moco/',
  targetRevision: '0.18.0',
  values: (importstr 'values.yaml'),
}
