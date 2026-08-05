local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'eck-operator',
  repoURL: 'https://helm.elastic.co',
  targetRevision: '3.5.0',
  values: (importstr 'values.yaml'),
}
