local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name + '-blackbox',
  namespace: app.namespace,
  chart: 'prometheus-blackbox-exporter',
  repoURL: 'https://prometheus-community.github.io/helm-charts',
  targetRevision: '11.18.0',
  values: (importstr 'blackbox-values.yaml'),
}
