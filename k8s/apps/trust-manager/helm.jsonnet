function(enableServiceMonitor=true) (import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'trust-manager',
  repoURL: 'https://charts.jetstack.io',
  targetRevision: 'v0.19.0',
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
