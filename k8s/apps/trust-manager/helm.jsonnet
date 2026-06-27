local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
local values = importstr 'values.yaml';
function(enableServiceMonitor=true) (helm) {
  name: app.name,
  namespace: app.namespace,
  chart: 'trust-manager',
  repoURL: 'https://charts.jetstack.io',
  targetRevision: 'v0.22.1',
  valuesObject: std.mergePatch(
    std.parseYaml(values), {
      app: {
        metrics: {
          service: {
            servicemonitor: {
              enabled: enableServiceMonitor,
            },
          },
        },
      },
    }
  ),
}
