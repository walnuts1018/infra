local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'redis-operator',
  repoURL: 'https://ot-container-kit.github.io/helm-charts/',
  targetRevision: '0.26.1',
  values: (importstr 'values.yaml'),
}
