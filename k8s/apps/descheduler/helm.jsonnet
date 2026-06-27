local app = import 'app.json5';
local values = importstr 'values.yaml';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'descheduler',
  repoURL: 'https://kubernetes-sigs.github.io/descheduler/',
  targetRevision: '0.36.0',
  values: (values),
}
