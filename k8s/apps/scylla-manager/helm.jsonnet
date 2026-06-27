local app = import 'app.json5';
function(enableServiceMonitor=true) (import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'scylla-manager',
  repoURL: 'https://scylla-operator-charts.storage.googleapis.com/stable',
  targetRevision: 'v1.21.0',
  values: (importstr 'values.yaml'),
}
