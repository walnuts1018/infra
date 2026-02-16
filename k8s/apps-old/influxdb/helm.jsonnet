(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'influxdb2',
  repoURL: 'https://helm.influxdata.com/',
  targetRevision: '2.1.2',
  values: (importstr 'values.yaml'),
}
