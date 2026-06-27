local app = import 'app.json5';
function(enableServiceMonitor=true) (import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'trust-manager',
  repoURL: 'https://charts.jetstack.io',
  targetRevision: 'v0.23.0',
  valuesObject: std.mergePatch(
    std.parseYaml(importstr 'values.yaml'), {
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
