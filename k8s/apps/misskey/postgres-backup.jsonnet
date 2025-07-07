{
  apiVersion: 'postgresql.cnpg.io/v1',
  kind: 'ScheduledBackup',
  metadata: {
    name: (import 'app.json5').name + '-postgresql-backup',
  },
  spec: {
    cluster: {
      name: (import 'postgres.jsonnet').metadata.name,
    },
    schedule: '0 0 18 * * *',
    backupOwnerReference: 'self',
    method: 'plugin',
    pluginConfiguration: {
      name: 'barman-cloud.cloudnative-pg.io',
    },
  },
}
