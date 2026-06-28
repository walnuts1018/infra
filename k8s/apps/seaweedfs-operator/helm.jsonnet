local app = import 'app.json5';
function(enableServiceMonitor=true) (import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'seaweedfs-operator',
  repoURL: 'https://seaweedfs.github.io/seaweedfs-operator/',
  targetRevision: '0.1.29',
  values: (importstr 'values.yaml'),
}
