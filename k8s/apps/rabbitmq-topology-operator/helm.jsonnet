(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'rabbitmq-topology-operator',
  repoURL: 'https://klicktipp.github.io/helm-charts/',
  targetRevision: '0.4.0',
  values: (importstr 'values.yaml'),
}
