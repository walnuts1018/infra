local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
local values = importstr 'values.yaml';
(helm) {
  name: app.name,
  namespace: app.namespace,
  chart: 'kube-state-metrics',
  repoURL: 'https://prometheus-community.github.io/helm-charts',
  targetRevision: '7.5.1',
  values: (values),
}
