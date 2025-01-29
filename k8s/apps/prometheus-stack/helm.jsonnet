(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'kube-prometheus-stack',
  repoURL: 'https://prometheus-community.github.io/helm-charts',
  targetRevision: '68.4.0',
  valuesObject: std.mergePatch(std.parseYaml(importstr 'values.yaml'), {
    prometheus: {
      prometheusSpec: {
        local storageSize = 32,
        storageSpec: {
          volumeClaimTemplate: {
            spec: {
              resources: {
                requests: {
                  storage: std.format('%dGi', storageSize),
                },
              },
            },
          },
        },
        retentionSize: std.format('%dGiB', storageSize * 0.75),
      },
    },
  }),
}
