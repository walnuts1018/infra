local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
local values = importstr 'values.yaml';
(helm) {
  name: app.name,
  namespace: app.namespace,

  chart: 'influxdb2',
  repoURL: 'https://helm.influxdata.com/',
  targetRevision: '2.1.2',
  values: (values),
}
