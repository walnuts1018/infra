local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
local values = importstr 'values.yaml';
function(enableServiceMonitor=true) (helm) {
  name: app.name,
  namespace: app.namespace,
  chart: 'cert-manager',
  repoURL: 'https://charts.jetstack.io',
  targetRevision: 'v1.20.2',
  valuesObject: std.mergePatch(
    std.parseYaml(values), {
      prometheus: {
        enabled: enableServiceMonitor,
        servicemonitor: {
          enabled: enableServiceMonitor,
        },
      },
    }
  ),
}
