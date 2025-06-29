{
  apiVersion: 'postgresql.cnpg.io/v1',
  kind: 'Cluster',
  metadata: {
    name: (import 'app.json5').name + '-postgresql',
  },
  spec: {
    instances: 3,
    storage: {
      size: '16Gi',
      storageClass: 'longhorn-local',
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
  },
}
