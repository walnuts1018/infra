local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'grafana',
  repoURL: 'https://grafana-community.github.io/helm-charts',
  targetRevision: '13.0.1',
  values: (importstr 'values.yaml'),
}
