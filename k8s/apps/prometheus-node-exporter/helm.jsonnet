local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'prometheus-node-exporter',
  repoURL: 'https://prometheus-community.github.io/helm-charts',
  targetRevision: '4.55.0',
  values: (importstr 'values.yaml'),
}
