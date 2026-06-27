local standard = import '../cloudnative-pg-image-catalog/standard.jsonnet';
local app = import 'app.json5';
local postgresBackupObjectstore = import 'postgres-backup-objectstore.jsonnet';
local postgresPassword = import 'postgres-password.jsonnet';
{
  apiVersion: 'postgresql.cnpg.io/v1',
  kind: 'Cluster',
  metadata: {
    name: app.name + '-postgresql',
  },
  spec: {
    instances: 2,
    imageCatalogRef: {
      apiGroup: 'postgresql.cnpg.io',
      kind: 'ClusterImageCatalog',
      name: standard.metadata.name,
      major: 17,
    },
    storage: {
      size: '10Gi',
      storageClass: 'local-path',
    },
    superuserSecret: {
      name: 'superuser-secret',
    },
    bootstrap: {
      initdb: {
        database: 'misskey',
        owner: 'misskey',
        secret: {
          name: postgresPassword.spec.target.name,
        },
      },
      // recovery: {
      //   source: 'seaweedfs-backup',
      // },
    },
    // externalClusters: [
    //   {
    //     name: 'seaweedfs-backup',
    //     plugin: {
    //       name: 'barman-cloud.cloudnative-pg.io',
    //       parameters: {
    //         barmanObjectName: 'seaweedfs-store',
    //         serverName: app.name + '-postgresql-backup2',
    //       },
    //     },
    //   },
    // ],
    resources: {
      requests: {
        cpu: '12m',
        memory: '662Mi',
      },
      limits: {
        cpu: '2',
        memory: '4Gi',
      },
    },
    plugins: [
      {
        name: 'barman-cloud.cloudnative-pg.io',
        isWALArchiver: true,
        parameters: {
          barmanObjectName: postgresBackupObjectstore.metadata.name,
        },
      },
    ],
    projectedVolumeTemplate: {
      sources: [
        {
          serviceAccountToken: {
            audience: 'sts.seaweedfs.com',
            expirationSeconds: 86400,
            path: 'sts.seaweedfs.com/serviceaccount/token',
          },
        },
      ],
    },
  },
}
