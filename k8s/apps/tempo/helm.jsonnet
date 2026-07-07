local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,

  chart: 'tempo-distributed',
  repoURL: 'https://grafana-community.github.io/helm-charts',
  targetRevision: '2.26.2',
  values: (importstr 'values.yaml'),
}
