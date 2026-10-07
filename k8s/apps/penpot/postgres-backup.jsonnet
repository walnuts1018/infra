local app = import 'app.json5';
{
  apiVersion: 'postgresql.cnpg.io/v1',
  kind: 'ScheduledBackup',
  metadata: {
    name: app.name + '-postgresql-backup',
    namespace: app.namespace,
  },
  spec: {
    cluster: {
      name: app.name + '-postgresql',
    },
    schedule: '0 0 18 * * *',
    backupOwnerReference: 'self',
    method: 'plugin',
    pluginConfiguration: {
      name: 'barman-cloud.cloudnative-pg.io',
    },
  },
}
