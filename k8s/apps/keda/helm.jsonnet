local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'keda',
  repoURL: 'https://kedacore.github.io/charts',
  targetRevision: '2.20.1',
  valuesObject: std.mergePatch(
    std.parseYaml(importstr 'values.yaml'), {
      clusterName: 'kurumi',
    }
  ),
}
