local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
local values = importstr 'values.yaml';
function(enableServiceMonitor=true) (helm) {
  name: app.name,
  namespace: app.namespace,
  chart: 'gpu-operator',
  repoURL: 'https://helm.ngc.nvidia.com/nvidia',
  targetRevision: 'v26.3.2',
  values: (values),
}
