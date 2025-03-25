(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'prometheus-snmp-exporter',
  repoURL: 'https://prometheus-community.github.io/helm-charts',
  targetRevision: '9.2.0',
  values: (importstr 'values.yaml'),
}
