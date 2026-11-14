local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,

  chart: 'prometheus-smartctl-exporter',
  repoURL: 'https://prometheus-community.github.io/helm-charts',
  targetRevision: '0.19.2',
  values: (importstr 'values.yaml'),
}
