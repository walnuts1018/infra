local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'cloudnative-pg',
  repoURL: 'https://cloudnative-pg.github.io/charts',
  targetRevision: '0.29.1',
  values: (importstr 'values.yaml'),
}
