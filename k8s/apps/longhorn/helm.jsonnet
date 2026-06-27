local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'longhorn',
  repoURL: 'https://charts.longhorn.io',
  targetRevision: '1.12.0',
  valuesObject: std.mergePatch(
    std.parseYaml(importstr 'values.yaml'),
    {
      defaultBackupStore: {
        backupTargetCredentialSecret: (import 'external-secret.jsonnet').spec.target.name,
      },
    }
  ),
}
