local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
local values = importstr 'values.yaml';
(helm) {
  name: app.name,
  namespace: app.namespace,
  chart: 'external-secrets',
  repoURL: 'https://charts.external-secrets.io',
  targetRevision: '2.6.0',
  values: (values),
}
