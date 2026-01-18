(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'caretta',
  repoURL: 'https://helm.groundcover.com/',
  targetRevision: '0.0.16',
  valuesObject: std.mergePatch(std.parseYaml(importstr 'values.yaml'), {
  }),
}
