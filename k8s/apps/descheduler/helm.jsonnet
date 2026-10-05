local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'descheduler',
  repoURL: 'https://kubernetes-sigs.github.io/descheduler/',
  targetRevision: '0.37.0',
  values: (importstr 'values.yaml'),
}
