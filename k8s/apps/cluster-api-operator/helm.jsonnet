local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
local values = importstr 'values.yaml';
(helm) {
  name: app.name,
  namespace: app.namespace,
  chart: 'cluster-api-operator',
  repoURL: 'https://kubernetes-sigs.github.io/cluster-api-operator',
  targetRevision: '0.27.0',
  valuesObject: std.parseYaml(values),
}
