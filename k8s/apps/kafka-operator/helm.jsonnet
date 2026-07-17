local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'strimzi-kafka-operator',
  repoURL: 'https://strimzi.io/charts/',
  targetRevision: '1.1.0',
  values: (importstr 'values.yaml'),
}
