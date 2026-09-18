local app = import 'app.json5';

(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'coder',
  repoURL: 'https://helm.coder.com/v2',
  targetRevision: '2.36.5',
  valuesObject: std.mergePatch(
    std.parseYaml(importstr 'values.yaml'),
  ),
}
