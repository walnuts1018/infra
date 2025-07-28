{
  apiVersion: 'postgresql.cnpg.io/v1',
  kind: 'Cluster',
  metadata: {
    name: (import 'app.json5').name + '-postgresql' + '-recover',
  },
  spec: {
    instances: 2,
    storage: {
      size: '10Gi',
      storageClass: 'longhorn',
    },
    superuserSecret: {
      name: 'superuser-secret',
    },
    bootstrap: {
      // initdb: {
      //   database: 'misskey',
      //   owner: 'misskey',
      //   secret: {
      //     name: (import 'postgres-password.jsonnet').spec.target.name,
      //   },
      // },
      recovery: {
        source: 'minio-backup',
      },
    },
    externalClusters: [
      {
        name: 'minio-backup',
        plugin: {
          name: 'barman-cloud.cloudnative-pg.io',
          parameters: {
            barmanObjectName: 'minio-store',
            serverName: (import 'app.json5').name + '-postgresql',
          },
        },
      },
    ],
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
