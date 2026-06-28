local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
(helm) {
  name: app.name,
  namespace: app.namespace,

  chart: 'influxdb2',
  repoURL: 'https://helm.influxdata.com/',
  targetRevision: '2.1.2',
  values: (importstr 'values.yaml'),
}
