(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  ociChartURL: 'ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set',
  targetRevision: '0.10.1',
  valuesObject: std.mergePatch(std.parseYaml(importstr 'values.yaml'), {
    githubConfigSecret: {
      githubConfigSecret: (import 'external-secret.jsonnet').spec.target.name,
    },
  }),
}
