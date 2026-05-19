function(enableServiceMonitor=true) (import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'gpu-operator',
  repoURL: 'https://helm.ngc.nvidia.com/nvidia',
  targetRevision: 'v26.3.1',
  values: (importstr 'values.yaml'),
}
