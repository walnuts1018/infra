local storage = import '../../components/storage.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'postgresql.cnpg.io/v1',
  kind: 'Cluster',
  metadata: {
    name: app.name + '-postgresql',
    namespace: app.namespace,
    annotations: {
      'argocd.argoproj.io/sync-wave': '-1',
    },
  },
  spec: {
    affinity: storage.avoidSlowNodeAffinity,
    instances: 3,
    imageCatalogRef: {
      apiGroup: 'postgresql.cnpg.io',
      kind: 'ClusterImageCatalog',
      name: (import '../cloudnative-pg-image-catalog/standard.jsonnet').metadata.name,
      major: 18,
    },
    storage: {
      size: '100Gi',
      storageClass: 'local-path',
    },
    bootstrap: {
      initdb: {
        database: 'penpot',
        owner: 'penpot',
        secret: {
          name: (import 'external-secret.jsonnet').metadata.name,
        },
      },
    },
    resources: {
      requests: {
        cpu: '200m',
        memory: '1Gi',
      },
      limits: {
        cpu: '2',
        memory: '4Gi',
      },
    },
    postgresql: {
      parameters: {
        max_connections: '200',
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
            audience: 'sts.seaweedfs.com',
            expirationSeconds: 86400,
            path: 'sts.seaweedfs.com/serviceaccount/token',
          },
        },
      ],
    },
  },
}
