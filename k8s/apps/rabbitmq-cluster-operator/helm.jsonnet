local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'rabbitmq-cluster-operator',
  repoURL: 'https://klicktipp.github.io/helm-charts/',
  targetRevision: '0.4.1',
  values: (importstr 'values.yaml'),
}
