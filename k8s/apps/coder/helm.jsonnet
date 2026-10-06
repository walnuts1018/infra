local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'coder',
  repoURL: 'https://helm.coder.com/v2',
  targetRevision: '2.38.0',
  values: (importstr 'values.yaml'),
}
