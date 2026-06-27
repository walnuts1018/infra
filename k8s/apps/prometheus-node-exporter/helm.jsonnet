local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
local values = importstr 'values.yaml';
(helm) {
  name: app.name,
  namespace: app.namespace,
  chart: 'prometheus-node-exporter',
  repoURL: 'https://prometheus-community.github.io/helm-charts',
  targetRevision: '4.55.0',
  values: (values),
}
