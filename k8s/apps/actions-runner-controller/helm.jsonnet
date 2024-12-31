(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'code-server-operator',
  repoURL: 'https://actions-runner-controller.github.io/actions-runner-controller',
  targetRevision: '0.23.7',
  valuesObject: std.mergePatch(std.parseYaml(importstr 'values.yaml'), {
    authSecret: {
      name: (import 'external-secret.jsonnet').spec.target.name,
    },
  }),
}
