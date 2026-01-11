{
  apiVersion: 'barmancloud.cnpg.io/v1',
  kind: 'ObjectStore',
  metadata: {
    name: 'seaweedfs-store',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    configuration: {
      destinationPath: 's3://cloudnative-pg-backup/',
      endpointURL: 'https://seaweedfs.local.walnuts.dev',
      s3Credentials: {
        inheritFromIAMRole: true,
      },
      data: {
        compression: 'bzip2',
      },
      wal: {
        compression: 'xz',
      },
    },
    retentionPolicy: '3d',
    instanceSidecarConfiguration: {
      env: [
        {
          name: 'AWS_WEB_IDENTITY_TOKEN_FILE',
          value: '/projected/sts.seaweedfs.com/serviceaccount/token',
        },
        {
          name: 'AWS_ENDPOINT_URL_STS',
          value: 'https://seaweedfs.local.walnuts.dev',
        },
        {
          name: 'AWS_REGION',
          value: 'us-east-1',
        },
        {
          name: 'AWS_ROLE_ARN',
          value: 'arn:aws:iam::role/cloudnative-pg-backup',
        },
      ],
    },
  },
}
