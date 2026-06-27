local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
local values = importstr 'values.yaml';
(helm) {
  name: app.name,
  namespace: app.namespace,

  chart: 'descheduler',
  repoURL: 'https://kubernetes-sigs.github.io/descheduler/',
  targetRevision: '0.36.0',
  values: (values),
}
