local standard = import '../cloudnative-pg-image-catalog/standard.jsonnet';
local app = import 'app.json5';
local databases = import 'databases.libsonnet';
local postgresBackupObjectstore = import 'postgres-backup-objectstore.jsonnet';
local postgresSuperuserPassword = import 'postgres-superuser-password.jsonnet';
{
  apiVersion: 'postgresql.cnpg.io/v1',
  kind: 'Cluster',
  metadata: {
    name: app.name,
  },
  spec: {
    instances: 3,
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
      name: postgresSuperuserPassword.spec.target.name,
    },
    enableSuperuserAccess: true,
    bootstrap: {
      initdb: {
        database: 'app',
        owner: 'app',
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
    //         serverName: 'postgresql-default2',
    //       },
    //     },
    //   },
    // ],
    managed: {
      roles: [{
        name: database.user_name,
        ensure: 'present',
        login: true,
        superuser: false,
        inRoles: ['pg_monitor', 'pg_signal_backend'],
        passwordSecret: {
          name: std.strReplace(database.user_name + '-db-password', '_', '-'),
        },
      } for database in (databases)],
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
