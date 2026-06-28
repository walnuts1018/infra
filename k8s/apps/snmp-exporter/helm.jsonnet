local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,

  chart: 'prometheus-snmp-exporter',
  repoURL: 'https://prometheus-community.github.io/helm-charts',
  targetRevision: '9.15.0',
  values: (importstr 'values.yaml'),
}
