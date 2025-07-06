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
    serviceAccountTemplate: {
      metadata: {
        name: (import 'app.json5').name + '-postgresql',
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
    env: [
      {
        name: 'AWS_CA_BUNDLE',
        value: '/projected/certificate/trust-bundle.pem',
      },
      {
        name: 'AWS_WEB_IDENTITY_TOKEN_FILE',
        value: '/projected/sts.min.io/serviceaccount/token',
      },
      {
        name: 'AWS_ENDPOINT_URL_STS',
        value: 'https://sts.minio-operator.svc.cluster.local:4223/sts/minio',
      },
      {
        name: 'AWS_REGION',
        value: 'ap-northeast-1',
      },
      {
        name: 'AWS_ROLE_ARN',
        value: 'arn:aws:iam::dummy:role/ipu',
      },
    ],
    projectedVolumeTemplate: {
      sources: [
        {
          serviceAccountToken: {
            audience: 'sts.min.io',
            expirationSeconds: 86400,
            path: 'token',
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
