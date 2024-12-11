(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'kubeshark',
  repoURL: 'https://helm.kubeshark.co/',
  targetRevision: '52.3.92',
  values: (importstr 'values.yaml'),
}
