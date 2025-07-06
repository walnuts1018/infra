{
  apiVersion: 'postgresql.cnpg.io/v1',
  kind: 'Cluster',
  metadata: {
    name: (import 'app.json5').name + '-postgresql',
  },
  spec: {
    instances: 2,
    storage: {
      size: '16Gi',
      storageClass: 'longhorn',
    },
    superuserSecret: {
      name: 'superuser-secret',
    },
    bootstrap: {
      initdb: {
        database: 'misskey',
        owner: 'misskey',
        secret: {
          name: (import 'postgres-password.jsonnet').spec.target.name,
        },
      },
    },
    resources: {
      requests: {
        cpu: '20m',
        memory: '150Mi',
      },
    },
    plugins: [
      {
        name: 'barman-cloud.cloudnative-pg.io',
        isWALArchiver: true,
        parameters: {
          barmanObjectName: (import '../cloudnative-pg-backup/objectstore.jsonnet').metadata.name,
        },
      },
    ],
  },
}
