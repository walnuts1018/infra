local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
local values = importstr 'values.yaml';
(helm) {
  name: app.name,
  namespace: app.namespace,

  chart: 'caretta',
  repoURL: 'https://helm.groundcover.com/',
  targetRevision: '0.0.16',
  valuesObject: std.mergePatch(std.parseYaml(values), {
  }),
}
