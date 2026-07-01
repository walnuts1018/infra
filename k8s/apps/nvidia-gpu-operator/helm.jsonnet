local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
function(enableServiceMonitor=true) (helm) {
  name: app.name,
  namespace: app.namespace,
  chart: 'gpu-operator',
  repoURL: 'https://helm.ngc.nvidia.com/nvidia',
  targetRevision: 'v26.3.3',
  values: (importstr 'values.yaml'),
}
