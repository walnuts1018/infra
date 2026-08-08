local app = import '../app.json5';
(import '../../../components/helm.libsonnet') {
  name: 'orchestra',
  namespace: app.namespace,
  chart: 'orchestra',
  repoURL: 'https://nexus.tremolo.io/repository/helm',
  targetRevision: '3.1.52',
  valuesObject: std.mergePatch(
    std.parseYaml(importstr '../values-common.yaml'),
    std.parseYaml(importstr 'values.yaml'),
  ),
}
