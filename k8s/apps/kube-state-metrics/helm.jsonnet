local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'kube-state-metrics',
  repoURL: 'https://prometheus-community.github.io/helm-charts',
  targetRevision: '7.5.2',
  values: (importstr 'values.yaml'),
}
