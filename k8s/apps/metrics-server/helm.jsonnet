local app = import 'app.json5';
local values = importstr 'values.yaml';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'metrics-server',
  repoURL: 'https://kubernetes-sigs.github.io/metrics-server/',
  targetRevision: '3.13.1',
  values: (values),
}
