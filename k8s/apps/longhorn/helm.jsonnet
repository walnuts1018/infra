local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
local values = importstr 'values.yaml';
local externalSecret = import 'external-secret.jsonnet';
(helm) {
  name: app.name,
  namespace: app.namespace,
  chart: 'longhorn',
  repoURL: 'https://charts.longhorn.io',
  targetRevision: '1.12.0',
  valuesObject: std.mergePatch(
    std.parseYaml(values),
    {
      defaultBackupStore: {
        backupTargetCredentialSecret: externalSecret.spec.target.name,
      },
    }
  ),
}
