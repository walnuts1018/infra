local app = import 'app.json5';
local postgres = import 'postgres.jsonnet';
{
  apiVersion: 'postgresql.cnpg.io/v1',
  kind: 'ScheduledBackup',
  metadata: {
    name: app.name + '-postgresql-backup',
  },
  spec: {
    cluster: {
      name: postgres.metadata.name,
    },
    schedule: '0 0 19 */7 * *',
    backupOwnerReference: 'self',
    method: 'plugin',
    pluginConfiguration: {
      name: 'barman-cloud.cloudnative-pg.io',
    },
  },
}
