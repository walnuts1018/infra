local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'cortex',
  repoURL: 'https://cortexproject.github.io/cortex-helm-chart',
  targetRevision: '3.3.8',
  values: (importstr 'values.yaml'),
}
