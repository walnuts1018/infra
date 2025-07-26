(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'opencost',
  repoURL: 'https://opencost.github.io/opencost-helm-chart',
  targetRevision: '2.1.7',
  values: (importstr 'values.yaml'),
}
