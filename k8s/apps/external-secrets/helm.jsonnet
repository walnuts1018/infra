local app = import 'app.json5';
local values = importstr 'values.yaml';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'external-secrets',
  repoURL: 'https://charts.external-secrets.io',
  targetRevision: '2.6.0',
  values: (values),
}
