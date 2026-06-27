local helm = import '../../components/helm.libsonnet';
local values = importstr 'values.yaml';
local app = import 'app.json5';
(helm) {
  name: app.name,
  namespace: app.namespace,
  chart: 'diode',
  repoURL: 'https://netboxlabs.github.io/diode/charts',
  targetRevision: '1.14.0',
  values: (values),
}
