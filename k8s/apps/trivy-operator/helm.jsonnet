local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'trivy-operator',
  repoURL: 'https://aquasecurity.github.io/helm-charts/',
  targetRevision: '0.35.0',
  valuesObject: std.mergePatch(std.parseYaml(importstr 'values.yaml'), {
  }),
}
