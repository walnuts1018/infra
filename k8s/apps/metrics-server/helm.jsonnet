local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'metrics-server',
  repoURL: 'https://kubernetes-sigs.github.io/metrics-server/',
  targetRevision: '3.14.0',
  values: (importstr 'values.yaml'),
}
