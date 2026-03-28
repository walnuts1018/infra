(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'trivy-operator',
  repoURL: 'https://aquasecurity.github.io/helm-charts/',
  targetRevision: '0.32.1',
  valuesObject: std.mergePatch(std.parseYaml(importstr 'values.yaml'), {
  }),
}
