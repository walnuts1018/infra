// SeaweedFSのAssumeRoleWithWebIdentity(IRSA相当)用の共通設定。
{
  env: [
    { name: 'AWS_WEB_IDENTITY_TOKEN_FILE', value: '/var/run/secrets/sts.seaweedfs.com/serviceaccount/token' },
    { name: 'AWS_ENDPOINT_URL_STS', value: 'https://seaweedfs.local.walnuts.dev' },
    { name: 'AWS_ROLE_ARN', value: 'arn:aws:iam::role/picca' },
  ],
  volume: {
    name: 'seaweedfs-sts-token',
    projected: {
      sources: [
        {
          serviceAccountToken: {
            audience: 'sts.seaweedfs.com',
            expirationSeconds: 86400,
            path: 'token',
          },
        },
      ],
    },
  },
  volumeMount: {
    name: 'seaweedfs-sts-token',
    mountPath: '/var/run/secrets/sts.seaweedfs.com/serviceaccount',
    readOnly: true,
  },
}
