local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'tenant',
  repoURL: 'https://operator.min.io/',
  targetRevision: '7.1.1',
  valuesObject: (import 'values.libsonnet'),
}
