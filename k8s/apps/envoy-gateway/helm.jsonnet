function() (import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  ociChartURL: 'docker.io/envoyproxy/gateway-helm',
  targetRevision: '1.5.1',
  valuesObject: std.mergePatch(
    std.parseYaml(importstr 'values.yaml'), {}
  ),
}
