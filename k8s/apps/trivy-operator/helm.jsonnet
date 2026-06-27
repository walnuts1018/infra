local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
local values = importstr 'values.yaml';
(helm) {
  name: app.name,
  namespace: app.namespace,

  chart: 'trivy-operator',
  repoURL: 'https://aquasecurity.github.io/helm-charts/',
  targetRevision: '0.33.1',
  valuesObject: std.mergePatch(std.parseYaml(values), {
  }),
}
