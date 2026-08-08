local app = import '../app.json5';
(import '../../../components/helm.libsonnet') {
  name: 'orchestra-login-portal',
  namespace: app.namespace,
  chart: 'orchestra-login-portal',
  repoURL: 'https://nexus.tremolo.io/repository/helm',
  targetRevision: '2.3.94',
  valuesObject: std.mergePatch(
    std.parseYaml(importstr '../values-common.yaml'),
    std.parseYaml(importstr 'values.yaml'),
  ),
}
