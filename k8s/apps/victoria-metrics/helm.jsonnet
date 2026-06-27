local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
local values = importstr 'values.yaml';
(helm) {
  name: app.name,
  namespace: app.namespace,

  chart: 'victoria-metrics-cluster',
  repoURL: 'https://victoriametrics.github.io/helm-charts/',
  targetRevision: '0.44.1',
  values: (values),
}
