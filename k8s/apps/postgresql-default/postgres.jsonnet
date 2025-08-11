{
  apiVersion: 'postgresql.cnpg.io/v1',
  kind: 'Cluster',
  metadata: {
    name: (import 'app.json5').name,
  },
  spec: {
    instances: 3,
    storage: {
      size: '10Gi',
      storageClass: 'local-path',
    },
    // superuserSecret: {
    //   name: 'superuser-secret',
    // },
    enableSuperuserAccess: true,
    bootstrap: {
      initdb: {
        database: 'app',
        owner: 'app',
      },
    },
    managed: {
      roles: [{
        name: database.user_name,
        ensure: 'present',
        login: true,
        superuser: false,
        inRoles: ['pg_monitor', 'pg_signal_backend'],
        passwordSecret: {
          name: database.user_name + '-db-password',
        },
      } for database in (import 'databases.libsonnet')],
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
          barmanObjectName: (import 'postgres-backup-objectstore.jsonnet').metadata.name,
        },
      },
    ],
    projectedVolumeTemplate: {
      sources: [
        {
          serviceAccountToken: {
            audience: 'sts.min.io',
            expirationSeconds: 86400,
            path: 'sts.min.io/serviceaccount/token',
          },
        },
        {
          configMap: {
            name: (import '../clusterissuer/local-bundle.jsonnet').metadata.name,
            items: [
              {
                key: 'trust-bundle.pem',
                path: 'certificate/trust-bundle.pem',
              },
            ],
          },
        },
      ],
    },
  },
}
