local app = import 'app.json5';
local values = importstr 'values.yaml';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'cloudnative-pg',
  repoURL: 'https://cloudnative-pg.github.io/charts',
  targetRevision: '0.28.3',
  values: (values),
}
