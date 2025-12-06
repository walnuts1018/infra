(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'terrakube',
  repoURL: 'https://charts.terrakube.io',
  targetRevision: '4.5.1',
  valuesObject: std.mergePatch(
    std.parseYaml(importstr 'values.yaml'),
    {
      api: {
        secrets: [
          'terrakube-api-secrets',
          (import 'external-secret-api.jsonnet').spec.target.name,
        ],
      },
      executor: {
        secrets: [
          'terrakube-executor-secrets',
          (import 'external-secret-executor.jsonnet').spec.target.name,
        ],
      },
      registry: {
        secrets: [
          'terrakube-registry-secrets',
          (import 'external-secret-registry.jsonnet').spec.target.name,
        ],
      },
    }
  ),
}
