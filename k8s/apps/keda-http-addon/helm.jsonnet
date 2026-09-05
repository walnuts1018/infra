local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'keda-add-ons-http',
  repoURL: 'https://kedacore.github.io/charts',
  targetRevision: '0.15.0',
  valuesObject: std.parseYaml(importstr 'values.yaml'),
}
