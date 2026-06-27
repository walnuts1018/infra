local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
function() (helm) {
  name: app.name,
  namespace: app.namespace,
  ociChartURL: 'docker.io/envoyproxy/gateway-helm',
  targetRevision: '1.6.1',
  valuesObject: std.mergePatch(
    std.parseYaml((importstr 'values.yaml')), {}
  ),
}
