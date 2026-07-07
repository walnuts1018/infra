local app = import 'app.json5';
function(enableServiceMonitor=true) (import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'cert-manager',
  repoURL: 'https://charts.jetstack.io',
  targetRevision: 'v1.20.3',
  valuesObject: std.mergePatch(
    std.parseYaml(importstr 'values.yaml'), {
      prometheus: {
        enabled: enableServiceMonitor,
        servicemonitor: {
          enabled: enableServiceMonitor,
        },
      },
    }
  ),
}
