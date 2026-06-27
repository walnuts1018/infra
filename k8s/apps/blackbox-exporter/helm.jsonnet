local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,

  chart: 'prometheus-blackbox-exporter',
  repoURL: 'https://prometheus-community.github.io/helm-charts',
  targetRevision: '11.12.0',
  values: (importstr 'values.yaml'),
}
