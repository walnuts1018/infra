(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'opencost',
  repoURL: 'https://opencost.github.io/opencost-helm-chart',
  targetRevision: '2.2.5',
  values: (importstr 'values.yaml'),
}
