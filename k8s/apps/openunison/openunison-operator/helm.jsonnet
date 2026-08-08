local app = import '../app.json5';
(import '../../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'openunison-operator',
  repoURL: 'https://nexus.tremolo.io/repository/helm',
  targetRevision: '3.0.30',
  valuesObject: std.parseYaml(importstr 'values.yaml'),
}
