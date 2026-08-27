local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,

  chart: 'tempo-distributed',
  repoURL: 'https://grafana-community.github.io/helm-charts',
  targetRevision: '3.5.1',
  values: (importstr 'values.yaml'),
}
