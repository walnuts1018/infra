local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'cluster-api-operator',
  repoURL: 'https://kubernetes-sigs.github.io/cluster-api-operator',
  targetRevision: '0.27.0',
  valuesObject: std.parseYaml((importstr 'values.yaml')),
}
