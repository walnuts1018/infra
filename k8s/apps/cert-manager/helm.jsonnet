function(enableServiceMonitor=true) (import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'cert-manager',
  repoURL: 'https://charts.jetstack.io',
  targetRevision: 'v1.19.0',
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
