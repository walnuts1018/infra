(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'velero',
  repoURL: 'https://vmware-tanzu.github.io/helm-charts',
  targetRevision: '11.0.0',
  valuesObject: std.mergePatch(
    std.parseYaml(importstr 'values.yaml'), {
    }
  ),
}
