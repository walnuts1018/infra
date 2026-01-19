function(enableServiceMonitor=true) (import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'seaweedfs-operator',
  repoURL: 'https://seaweedfs.github.io/seaweedfs-operator/',
  targetRevision: '0.1.12',
  values: (importstr 'values.yaml'),
}
