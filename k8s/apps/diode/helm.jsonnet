local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'diode',
  repoURL: 'https://netboxlabs.github.io/diode/charts',
  targetRevision: '1.14.0',
  values: (importstr 'values.yaml'),
}
