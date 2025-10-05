(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'longhorn',
  repoURL: 'https://charts.longhorn.io',
  targetRevision: '1.10.0',
  valuesObject: std.mergePatch(
    std.parseYaml(importstr 'values.yaml'),
    {
      defaultBackupStore: {
        backupTargetCredentialSecret: (import 'external-secret.jsonnet').spec.target.name,
      },
    }
  ),
}
