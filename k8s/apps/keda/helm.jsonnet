local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'keda',
  repoURL: 'https://kedacore.github.io/charts',
  targetRevision: '2.21.0',
  valuesObject: std.mergePatch(
    std.parseYaml(importstr 'values.yaml'), {
      clusterName: 'kurumi',
    }
  ),
}
