local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,

  chart: 'victoria-metrics-cluster',
  repoURL: 'https://victoriametrics.github.io/helm-charts/',
  targetRevision: '0.44.2',
  values: (importstr 'values.yaml'),
}
