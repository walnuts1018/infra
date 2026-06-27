local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
local values = importstr 'values.yaml';
(helm) {
  name: app.name,
  namespace: app.namespace,
  chart: 'cloudnative-pg',
  repoURL: 'https://cloudnative-pg.github.io/charts',
  targetRevision: '0.28.3',
  values: (values),
}
