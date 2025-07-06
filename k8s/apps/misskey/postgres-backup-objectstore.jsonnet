{
  apiVersion: 'barmancloud.cnpg.io/v1',
  kind: 'ObjectStore',
  metadata: {
    name: 'minio-store',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    configuration: {
      destinationPath: 's3://cloudnative-pg-backup/',
      endpointURL: 'http://minio.minio.svc.cluster.local',
      s3Credentials: {
        inheritFromIAMRole: true,
      },
      wal: {
        compression: 'gzip',
      },
    },
    retentionPolicy: '14d',
    instanceSidecarConfiguration: {
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
    },
  },
}
