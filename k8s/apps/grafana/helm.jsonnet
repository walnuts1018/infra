local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
local values = importstr 'values.yaml';
(helm) {
  name: app.name,
  namespace: app.namespace,
  chart: 'grafana',
  repoURL: 'https://grafana-community.github.io/helm-charts',
  targetRevision: '12.4.8',
  values: (values),
}
